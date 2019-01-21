#Add-Additional-AD-Groups-To-Server-Experianuk.ps1
#Nigel Benton
#Tested on Windows 2012 /2012 R2 in ipani.uk.experian.com domain.

#v1.0 26/4/16
#v1.1 3/8/16 Added accounts for service now and arcsight logging
#v1.2 25/9/17 extra steps for 2008.

#Determine Windows Version
$OSName = (Get-WmiObject Win32_OperatingSystem).Caption

#Note these accounts may already be added via GPO so will error when run
([ADSI]"WinNT://./Administrators").Add("WinNT://ipani.uk.experian.com/taddmuser")
([ADSI]"WinNT://./Administrators").Add("WinNT://ipani.uk.experian.com/ts-t-hs-serverops")
([ADSI]"WinNT://./Administrators").Add("WinNT://ipani.uk.experian.com/ts command centre all users")
([ADSI]"WinNT://./Remote Desktop Users").Add("WinNT://ipani.uk.experian.com/ADMIN Storage Administration")
([ADSI]"WinNT://./Administrators").Add("WinNT://ipani.uk.experian.com/sndipaniuk")
([ADSI]"WinNT://./Event Log Readers").Add("WinNT://ipani.uk.experian.com/ArcSight")

if($OSName -match '2008')
{

Write-Output "Windows 2008/2008R2, add accounts with the deny interactive logon right as not done with GPOs on 2008 in IPANIUK Domain."

c:\tmp\ntrights.exe +r SeDenyInteractiveLogonRight -u IPANIUK\taddmuser

c:\tmp\ntrights.exe +r SeDenyInteractiveLogonRight -u IPANIUK\sndipaniuk

}