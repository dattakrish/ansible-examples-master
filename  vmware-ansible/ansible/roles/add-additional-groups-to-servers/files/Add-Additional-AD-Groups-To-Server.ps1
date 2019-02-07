#Add-Additional-AD-Groups-To-Server-Experianuk.ps1
#Nigel Benton
#v1.0 28th November 2017
#v1.1 13th Dec 2018 remove references to TADDM

#Determine Windows Version
$OSName = (Get-WmiObject Win32_OperatingSystem).Caption

"The OS is $OSName."

#Determine Windows Domain
$Domain = (Get-WmiObject WIN32_ComputerSystem).Domain

"The domain is $Domain."

switch ($Domain)
{
    'gdc.local' 
    {
    "gdc.local"
    #Note these accounts may already be added via GPO so will error when run
    ([ADSI]"WinNT://./Administrators").Add("WinNT://gdc.local/ADMIN DSG Engineers")
    ([ADSI]"WinNT://./Administrators").Add("WinNT://gdc.local/ADMIN EGOC Operations")
    #([ADSI]"WinNT://./Administrators").Add("WinNT://gdc.local/taddmuser")
    ([ADSI]"WinNT://./Administrators").Add("WinNT://gdc.local/sndlgdc")
    ([ADSI]"WinNT://./Administrators").Add("WinNT://gdc.local/ADMIN Windows Server Administration")
    ([ADSI]"WinNT://./Event Log Readers").Add("WinNT://gdc.local/ArcSvc")
    ([ADSI]"WinNT://./Administrators").Remove("WinNT://gdc.local/Domain Admins")
    }

    'uk.experian.local' 
    {
    "uk.experian.local"
    #Note these accounts may already be added via GPO so will error when run
    ([ADSI]"WinNT://./Administrators").Add("WinNT://uk.experian.local/tdmukuser")
    ([ADSI]"WinNT://./Administrators").Add("WinNT://uk.experian.local/ts-t-hs-serverops")
    ([ADSI]"WinNT://./Administrators").Add("WinNT://uk.experian.local/ts command centre all users")
    ([ADSI]"WinNT://./Remote Desktop Users").Add("WinNT://uk.experian.local/ADMIN Storage Administration")
    ([ADSI]"WinNT://./Administrators").Add("WinNT://uk.experian.local/snduk")
    ([ADSI]"WinNT://./Event Log Readers").Add("WinNT://uk.experian.local/Arcsight")
    #Note the following groups may get added if the computer account is put into the computers OU by mistake
    #This will error if accounts are not in the group
    ([ADSI]"WinNT://./Administrators").Remove("WinNT://ena.us.experian.local/ADMIN Systems Management")
    ([ADSI]"WinNT://./Administrators").Remove("WinNT://uk.experian.local/ADMIN Workstation Administration")
    ([ADSI]"WinNT://./Administrators").Remove("WinNT://uk.experian.local/CL-T-DskAdmin")
    ([ADSI]"WinNT://./Administrators").Remove("WinNT://uk.experian.local/CP-T-ACGLocalAdmin")
    ([ADSI]"WinNT://./Administrators").Remove("WinNT://uk.experian.local/Dept_BN_PCSupport")
    ([ADSI]"WinNT://./Administrators").Remove("WinNT://uk.experian.local/MarAppInstall")
    ([ADSI]"WinNT://./Administrators").Remove("WinNT://uk.experian.local/SSMgmtWKUKSvc")
    ([ADSI]"WinNT://./Administrators").Remove("WinNT://uk.experian.local/Domain Admins")   
    }

    'ipani.uk.experian.com' 
    {
    "ipani.uk.experian.com"
    #Note these accounts may already be added via GPO so will error when run
    #([ADSI]"WinNT://./Administrators").Add("WinNT://ipani.uk.experian.com/taddmuser")
    ([ADSI]"WinNT://./Administrators").Add("WinNT://ipani.uk.experian.com/ts-t-hs-serverops")
    ([ADSI]"WinNT://./Administrators").Add("WinNT://ipani.uk.experian.com/ts command centre all users")
    ([ADSI]"WinNT://./Remote Desktop Users").Add("WinNT://ipani.uk.experian.com/ADMIN Storage Administration")
    ([ADSI]"WinNT://./Administrators").Add("WinNT://ipani.uk.experian.com/sndipaniuk")
    ([ADSI]"WinNT://./Event Log Readers").Add("WinNT://ipani.uk.experian.com/ArcSight")

    if($OSName -match '2008')
    {

    Write-Output "Windows 2008/2008R2, add accounts with the deny interactive logon right as not done with GPOs on 2008 in IPANIUK Domain."

    #c:\tmp\ntrights.exe +r SeDenyInteractiveLogonRight -u IPANIUK\taddmuser

    c:\tmp\ntrights.exe +r SeDenyInteractiveLogonRight -u IPANIUK\sndipaniuk

    }  
      
    }

    'WORKGROUP' 
    {
    "Workgroup."
    #Nothing to do.
    }

    Default {"The $Domain domain is not supported by this script so no changes made."}
}