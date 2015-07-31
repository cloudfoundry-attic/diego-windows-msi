[![Build status](https://ci.appveyor.com/api/projects/status/q41mqu9vb34ljxtq/branch/master?svg=true)](https://ci.appveyor.com/project/greenhouse/diego-windows-msi/branch/master)

# Welcome to Diego on Windows

Our end user documentation (currently a work in progress) is available here: http://docs.pivotal.io/pivotalcf/opsguide/deploying-diego.html

1. [About Branches](#about-branches)
1. [Repository Contents](#repository-contents)
1. [Building the MSI](#building-the-msi)
1. [Installing the MSI](#install-the-msi)
1. [CI](#CI)
1. [Ask Questions](#ask-questions)
1. [Tracker](#tracker)

## About Branches

Currently, all development is done directly on the master branch. Commits that have passed through all of CI are tagged with a monotoncially increasing version number.


## Repository Contents

This repo contains submodules with all of the source requirements to run a
Windows Cell for Cloud Foundry (Diego). After an install all of the necessary
programs (consul, containerizer, garden-windows, executor, rep) will be running
as services and logging to windows events.


## Building the MSI

For instructions on how to build the msi see [Building instructions](docs/BUILDING.md).

## Installing the MSI

To install the MSI refer to the [installation instructions](docs/INSTALL.md).

## CI

In addition to the [AppVeyor build](https://ci.appveyor.com/project/greenhouse/diego-windows-msi/branch/master) that runs cell specific integration tests, there is also a [concourse pipeline](https://diego.ci.cf-app.com/?groups=greenhouse) that tests the system from the perspective of the [CF cli](https://github.com/cloudfoundry/cli).


## Ask Questions

Join our slack channel at https://cloudfoundry.slack.com/messages/greenhouse/

## Tracker

https://www.pivotaltracker.com/n/projects/1156164
