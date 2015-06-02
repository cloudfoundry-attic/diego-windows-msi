Configuration CFWindows {
Node "localhost" {

WindowsFeature IISWebServer {
Ensure = "Present"
Name = "Web-Webserver"
}
WindowsFeature WebSockets {
Ensure = "Present"
Name = "Web-WebSockets"
}
WindowsFeature WebServerSupport {
Ensure = "Present"
Name = "AS-Web-Support"
}
WindowsFeature DotNet {
Ensure = "Present"
Name = "AS-NET-Framework"
}
WindowsFeature HostableWebCore {
Ensure = "Present"
Name = "Web-WHC"
}

Script SetupDNS {
    SetScript = {
        Set-DnsClientServerAddress -InterfaceAlias Ethernet0 -ServerAddresses 127.0.0.1,8.8.4.4
    }
    GetScript = {
        Get-DnsClientServerAddress -AddressFamily ipv4 -InterfaceAlias Ethernet0
    }    
    TestScript = {        
        if(@(Compare-Object -ReferenceObject (Get-DnsClientServerAddress -InterfaceAlias Ethernet0 -AddressFamily ipv4 -ErrorAction Stop).ServerAddresses -DifferenceObject 127.0.0.1,8.8.4.4).Length -eq 0)
        {
        Write-Verbose -Message "DNS Servers are set correctly."
        return $true
        }
        else
        {
        Write-Verbose -Message "DNS Servers not yet correct."
        return $false
        }
    }
}

Script DisableDNSCache
{
    SetScript = {
        Set-Service -Name Dnscache -StartupType Disabled
        Stop-Service -Name Dnscache
    }
    GetScript = {
        Get-Service -Name Dnscache
    }
    TestScript = {
        return @(Get-Service -Name Dnscache).Status -eq "Stopped"
    }
}
}
}

CFWindows
Start-DscConfiguration -Wait -Verbose -Path .\CFWindows -Force