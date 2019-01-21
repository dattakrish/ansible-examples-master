#Add-Additional-AD-Groups-To-Server-Experianuk.ps1
#Nigel Benton
#Tested on Windows 2012/2012 R2 in uk.experian.local domain.

#v1.0 7/3/16
#v1.1 21/4/16 Added Admin Storage Administration Group. Added command to remove other groups
#v1.1 03/08/16 Added accounts for service now and arcsight logging
#v1.2 10/02/17 Remove Domain Admins from local administrators


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
