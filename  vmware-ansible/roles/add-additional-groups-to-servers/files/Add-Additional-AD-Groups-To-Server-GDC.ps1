#Add-Additional-AD-Groups-To-Server-GDC.ps1
#Nigel Benton
#Tested on Windows 2012 /2012 R2 in gdc.local domain.
#v1.0 7/3/16
#v1.1 3/8/16 Added accounts for service now and arcsight logging
#v1.2 10/2/17 Remove Domain Admins From Local Administrators
#v1.3 14/3/17 Add ADMIN Windows Server Administration

([ADSI]"WinNT://./Administrators").Add("WinNT://gdc.local/ADMIN DSG Engineers")
([ADSI]"WinNT://./Administrators").Add("WinNT://gdc.local/ADMIN EGOC Operations")
([ADSI]"WinNT://./Administrators").Add("WinNT://gdc.local/taddmuser")
([ADSI]"WinNT://./Administrators").Add("WinNT://gdc.local/sndlgdc")
([ADSI]"WinNT://./Administrators").Add("WinNT://gdc.local/ADMIN Windows Server Administration")
([ADSI]"WinNT://./Event Log Readers").Add("WinNT://gdc.local/ArcSvc")
([ADSI]"WinNT://./Administrators").Remove("WinNT://gdc.local/Domain Admins")