#!/usr/bin/env ruby

require 'net/ssh'
require 'net/ssh/gateway'

DEPLOYMENTS_RUNTIME = ENV['DEPLOYMENTS_RUNTIME'] or raise "Please set env var DEPLOYMENTS_RUNTIME"
ADMIN_PASS = ENV['ADMIN_PASS'] or raise "Please set env var ADMIN_PASS"
JUMP_MACHINE_IP = ENV['JUMP_MACHINE_IP']
MACHINE_IP = ENV['MACHINE_IP'] or raise "Please set env var MACHINE_IP"
CONSUL_IPS = ENV['CONSUL_IPS'] or raise "Please set env var CONSUL_IPS"
ETCD_CLUSTER = ENV['ETCD_CLUSTER'] or raise "Please set env var ETCD_CLUSTER"
CF_ETCD_CLUSTER = ENV['CF_ETCD_CLUSTER'] or raise "Please set env var CF_ETCD_CLUSTER"
ZONE = ENV['ZONE'] or raise "Please set env var ZONE"

options = {
  auth_methods: ["publickey"],
  use_agent: false,
  keys: ["#{DEPLOYMENTS_RUNTIME}/keypair/id_rsa_bosh"]
}

if ARGV[0] =~/DiegoWindowsMSI-(\d+(?:\.(\d+))*)-([0-9a-f]+).msi$/
  BUILD_VERSION = $1
  EXPECTED_SHA = $3
  MSI_DOWNLOAD_URL = "https://s3.amazonaws.com/diego-windows-msi/output/DiegoWindowsMSI-#{BUILD_VERSION}-#{EXPECTED_SHA}.msi"
else
  puts "USAGE: Please provide msi filename"
  puts ARGV[0]
  exit 1
end

msi_location="c:\\diego.msi"
block = ->(ssh) do
  hostname = ssh.exec!("hostname").chomp
  puts "Hostname: #{hostname}"

  puts "Uninstall"
  puts ssh.exec!("msiexec /norestart /passive /x #{msi_location}")
  ssh.exec!("del /Y #{msi_location}")

  puts "Downloading msi from #{MSI_DOWNLOAD_URL}"
  puts ssh.exec!("powershell /C wget #{MSI_DOWNLOAD_URL} -OutFile #{msi_location}")

  puts "Install"
  puts ssh.exec!("msiexec /norestart /passive /i #{msi_location} CONTAINERIZER_USERNAME=.\\Administrator CONTAINERIZER_PASSWORD=#{ADMIN_PASS} EXTERNAL_IP=#{MACHINE_IP} CONSUL_IPS=#{CONSUL_IPS} ETCD_CLUSTER=#{ETCD_CLUSTER} CF_ETCD_CLUSTER=#{CF_ETCD_CLUSTER} LOGGREGATOR_SHARED_SECRET=loggregator-secret MACHINE_NAME=#{hostname} STACK=windows2012R2 ZONE=#{ZONE}")

  output = ssh.exec!("powershell /C type $Env:ProgramW6432/CloudFoundry/DiegoWindows/RELEASE_SHA")
  actual_sha = output.chomp.split(/\s+/).last
  puts actual_sha.inspect

  if actual_sha != EXPECTED_SHA
    puts "Installation failed: expected #{EXPECTED_SHA}, got #{actual_sha}"
    exit(1)
  end
  puts "Installation succeeded, #{EXPECTED_SHA} == #{actual_sha}"
end

if JUMP_MACHINE_IP
  gateway = Net::SSH::Gateway.new(JUMP_MACHINE_IP, 'ec2-user', options)
  gateway.ssh(MACHINE_IP, "ci", options, &block)
else
  Net::SSH.start(MACHINE_IP, "ci", options, &block)
end
