Param (
[ValidateLength(12,15)][string]$targetLicenseServer,               #target RDS License Server.
[ValidateSet(“True”,”False”)] [string]$isRDSLicenseServer="True",  #Is this RDS installation a License Server, Default is yes.
[ValidateRange(2,4)][Int]$licenseMode=4                           #validate setCals is 2 or 4.
)

## Add required Power Shell modules
Import-Module RemoteDesktop 

## PS to get FQDN
$myFQDN=(Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain

### If RDS Licensing to be installed locally, add feature and configure
if ($isRDSLicenseServer -eq "True") {
#    Add-WindowsFeature RDS-Licensing, RDS-Licensing-UI

    #$LicMode = Read-Host("Please enter the licensing mode this server will run under.  Type '2' for Per Device, Type '4' for Per User")
    $obj = gwmi -namespace "Root/CIMV2/TerminalServices" Win32_TerminalServiceSetting
    $LicStatChange = $obj.ChangeMode($licenseMode)
    $LicServUpdate = $obj.SetSpecifiedLicenseServerList($myFQDN)
    if($LicStatChange.ReturnValue -eq 0)
    {
     Write-Host("Licensing Mode Set Successfully")
    }
    else
    {
        Write-Host("ERROR:  Licensing Mode Could NOT Be Set")
    }
    if($LicServUpdate.ReturnValue -eq 0)
    {
        Write-Host("Licensing Server Set To $myFQDN")
    }
    else
    {
        Write-Host("ERROR:  Licensing Server Could NOT Be Set")
    }
    Start-Process "licmgr.exe"

}
Else{
    #$licsrv = Read-Host("Please enter the IP or hostname of the licensing server.")
    #$LicMode = Read-Host("Please enter the licensing mode this server will run under.  Type '2' for Per Device, Type '4' for Per User")
    $obj = gwmi -namespace "Root/CIMV2/TerminalServices" Win32_TerminalServiceSetting
    $LicStatChange = $obj.ChangeMode($licenseMode)
    $LicServUpdate = $obj.SetSpecifiedLicenseServerList($targetLicenseServer)
    if($LicStatChange.ReturnValue -eq 0)
    {
     Write-Host("Licensing Mode Set Successfully")
    }
    else
    {
        Write-Host("ERROR:  Licensing Mode Could NOT Be Set")
    }
    if($LicServUpdate.ReturnValue -eq 0)
    {
        Write-Host("Licensing Server Configured as: $targetLicenseServer")
    }
    else
    {
        Write-Host("ERROR:  Licensing Server Could NOT Be Set")
    }
}