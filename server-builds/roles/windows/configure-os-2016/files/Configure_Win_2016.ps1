Param (
[ValidateLength(12,15)][string]$NewComputerName=$env:computername, #New Server name. Should be between 12 and 15 characters. Default is current name.
[ValidateSet(“UK”,”US”,"APAC","none")][string]$Region="none",      #Used to apply SNMP region specific configuration. Default is none, no settings applied.
[string]$PrimaryAdapterCurrentName="ethernet",                     #Current name of the "Primary" adapter. Default is "ethernet"
[ValidateSet(“yes”,”no”)] [string]$BackupAdapterInstalled="no",    #Is a backup adapter installed? Default is no.
[ValidateSet(“yes”,”no”)][string]$YDriveRequired="yes",            #Does a Y drive need to be created? Default is yes. Must be disk 1
[string]$BackupAdapterCurrentName="ethernet 2",                    #current name of the "Backup" adapter if installed. Default is "ethernet 2"
[ipaddress]$PrimaryIP="0.0.0.0",                                   #Primary Adapter IP. Default is 0.0.0.0 which does not set a value.
[ValidateRange(8,32)][Int]$PrimaryPL=24,                           #Primary Adapter Prefix length. Default is 24.
[ipaddress]$PrimaryGW="0.0.0.0",                                   #Primary Adapter Gateway. Default is 0.0.0.0 which does not set a value.
[string]$PrimaryDNS="0.0.0.0",                                     #Primary Adapter DNS Servers. Default is 0.0.0.0 which does not set a value.
[string]$PrimarySuffix="",                                         #Primary Adapter DNS suffix. Default is empty which does not set a value.
[ipaddress]$BackupIP="0.0.0.0",                                    #Backup Adapter IP. Default is 0.0.0.0 which does not set a value.
[ValidateRange(8,32)][Int]$BackupPL=24,                            #Backup Adapter Prefix length. Default is 24
[ipaddress]$BackupGW="0.0.0.0",                                    #Backup Adapter Gateway. Default is 0.0.0.0 which does not set a value.
[string]$BackupDNS="0.0.0.0",                                      #Backup Adapter DNS suffix. Default is empty which does not set a value.
[string]$BackupSuffix="",                                          #Backup Adapter DNS suffix. Default is empty which does not set a value.
[ValidateSet(“yes”,”no”)][string]$AddToDomain="no",                #Should the server be added to a domain. Default is no.
[string]$DomainFQDN="",                                            #AD Domain if being added to a domain.Also updates Primary Adapter DNS Suffix. Use FQDN not netbios name. Default is empty. You will be prompted for creds.
[ValidateSet(“yes”,”no”)][string]$DisableBuiltInAdminAcct="yes",   #Disable the built in administrator account. Default is yes.
#[ValidateLength(12,50)][string]$SS000DA_PWD="",                    #Password for the SS000DA Account. If no password is passed the script will generate a password.
#[ValidateSet(“yes”,”no”)][string]$CreateTempDirs="yes",            #Create c:\tmp and c:\temp directories and secure NTFS permissions. Default is yes.
[ValidateSet(“yes”,”no”)][string]$ApplyLGPO="yes"                   #Apply local gpo. Default is yes.
#[ValidateSet(“yes”,”no”)][string]$ApplysecurityReg="yes"           #Apply security rollup registry file. Default is yes.
#[ValidateSet(“yes”,”no”)][string]$RestartServer="yes"              #Restarts the server.Default is yes.
)

Function Get-Password() {

$ascii=$NULL;For ($a=33;$a –le 126;$a++) {$ascii+=,[char][byte]$a }

For ($loop=1; $loop –le 40; $loop++) 

{$Password+=($ascii | Get-Random)}

return $Password

}

Clear-Host

Write-Output "This script should be run from the console host and not the ISE."
Write-Output "Ensure that all network interfaces that will be used are plugged in and have a link before running this script."
Write-Output "If network interfaces need teaming this should be carried out before running this script."
Write-Output "If additional network interfaces are connected after the script is run NETBIOS and other network bindings may need uninstalling / disabling."
Write-Output "If a Y drive is required it needs to be presented as disk 1 to the server."
Write-Output "If adding the server to a domain the Windows Server 2016 Member Servers OU must exist. You will be prompted for credentials."
Write-Output "By default the script disables the built in administrator account. Ensure you have another account to log on with."

Start-Sleep -Seconds 30

################################################################################################################
# Configure MPIO If not a VM
Write-Output "Configure MPIO If not a VM."
if((Get-WmiObject -Class Win32_ComputerSystem).model -notmatch 'VMware')
{
    New-MSDSMSupportedHW -VendorId "HITACHI" -ProductId "OPEN-V"
    Update-MPIOClaimedHW -Confirm:$false
    Write-Output "MPIO Configuration Complete."
}

Start-Sleep -Seconds 5

################################################################################################################
#To configure Windows Firewall to allow MMC snap-in(s) etc to connect (if firewall has to be enabled at a later date)
Write-Output "Configure Windows Firewall to allow MMC snap-in(s) etc to connect."
Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Enabled True
Set-NetFirewallRule -DisplayGroup "Remote Service Management" -Enabled True
Set-NetFirewallRule -DisplayGroup "Performance Logs and Alerts" -Enabled True
Set-NetFirewallRule -DisplayGroup "Remote Event Log Management" -Enabled True
Set-NetFirewallRule -DisplayGroup "Remote Scheduled Tasks Management" -Enabled True
Set-NetFirewallRule -DisplayGroup "Remote Volume Management" -Enabled True
Set-NetFirewallRule -DisplayGroup "Windows Firewall Remote Management" -Enabled True
Set-NetFirewallRule -DisplayGroup "windows management instrumentation (wmi)" -Enabled True
Start-Sleep -Seconds 5

#Following rules do not appear to be in Server Core
if((Get-ItemProperty -name installationtype 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').InstallationType -eq "Server")
{
    Write-Output "Server is not Core, Processing additional firewall Configuration."
    Set-NetFirewallRule -DisplayGroup "Com+ Network Access" -Enabled True
    Set-NetFirewallRule -DisplayGroup "Com+ Remote Administration" -Enabled True
}

Start-Sleep -Seconds 5

###########################################################################
#Ensure Primary Adapter is named "Primary"

if((get-netadapter).Name -match "Primary"){"Adapter called primary already exists so no need to rename"}
Else
{
    #Adapter is not called Primary so rename
    Write-Output "Adapter is not called Primary so renaming."
    get-netadapter | Where-Object { $_.name -eq "$PrimaryAdapterCurrentName" } | Rename-NetAdapter –NewName ‘Primary’ ; Write-Output "Renaming Adapter $PrimaryAdapterCurrentName to Primary." ;Start-Sleep -Seconds 5
    if((get-netadapter).Name -match "Ethernet0"){Rename-NetAdapter –Name ‘Ethernet0’ –NewName ‘Primary’}  #Synergy Templates
}

###########################################################################
#If $DomainFQDN is passed set DNS suffix to it

if($DomainFQDN)
{
    Write-Output "Setting Domain FQDN."
    Set-DNSClient –InterfaceAlias ‘Primary’ –ConnectionSpecificSuffix $DomainFQDN   
}

##################################################################
#If Backup Adapter is installed rename to "Backup" and unbind ms_msclient and ms_server

if($BackupAdapterInstalled -eq "yes")
{
    #See if adapter called backup already exists, if not rename
    if((get-netadapter).Name -match "Backup"){"adapter called backup already exists so no need to rename"}
    Else
    {
        #Adapter is not called Backup so rename
        get-netadapter | Where-Object { $_.name -eq "$BackupAdapterCurrentName" } | Rename-NetAdapter –NewName ‘Backup’; Write-Output "Renaming Adapter $BackupAdapterCurrentName to Backup." ;Start-Sleep -Seconds 5
        if((get-netadapter).Name -match "Ethernet1"){Rename-NetAdapter –Name ‘Ethernet1’ –NewName ‘Backup’}  #Synergy Templates
    }

    #Bug in vmware where you have to define a DNS address in customisation scripts. Reset this in case it has been applied.
    Set-DNSClientServerAddress –InterfaceAlias ‘Backup’ –ResetServerAddresses

    #Unbind file and printer sharing and client for MS Networks.
    Write-Output "Unbind file and printer sharing and client for MS Networks on the Backup Interface."
    Start-Sleep -Seconds 5
    Set-NetAdapterBinding -Name 'Backup' –ComponentID ms_msclient, ms_server  –Enabled $False
    #Backup Interface disable DNS Registration
    Write-Output "Disable DNS Registration on the Backup Interface."
    Start-Sleep -Seconds 5
    Set-DNSClient –InterfaceAlias ‘Backup’ –RegisterThisConnectionsAddress $false

    #Set the connection profile to Private
    Write-Output "Set the connection profile to private for the  backup adapter."
    Start-Sleep -Seconds 5
    Get-NetConnectionProfile -InterfaceAlias "Backup" | Set-NetConnectionProfile -NetworkCategory Private

    Start-Sleep -Seconds 5
}


#####################################################################
#Unbind IPv6 on all interfaces
#This always seems to error on Server 2016 but seems to apply setting. MS have confirmed this is a bug and are investigating (Jan 2017)
#Need to test that this setting has been applied later in the build jobs.
#Set to silently continue until MS have a fix.
Write-Output "Unbind IPv6 on all visible interfaces"
Start-Sleep -Seconds 5
Get-NetAdapterBinding | Set-NetAdapterBinding –ComponentID ms_tcpip6 –Enabled $False -EA SilentlyContinue
Start-Sleep -Seconds 5

###########################################################################
#Disable NetBIOS for all network interfaces.
#Adapters need to be enabled and plugged in.
#0 EnableNetbiosViaDhcp
#1 EnableNetbios
#2 DisableNetbios

Write-Output "Disable NetBIOS for all network interfaces. This will fail on interfaces which are disconnected."
Start-Sleep -Seconds 5
$Adapters=(Get-WmiObject Win32_networkadapterconfiguration)
$Adapters.settcpipnetbios(2)
Start-Sleep -Seconds 5

#####################################################################
#Disable WINS LMHosts lookup
Write-Output "Disable WINS LMHosts lookup."
Start-Sleep -Seconds 5
([wmiclass]’win32_NetworkAdapterConfiguration’).EnableWins($null,$false)
Start-Sleep -Seconds 5

###################################################################################################
#Disable any network adapters not matching Primary, Backup, Heartbeat or Cluster  or Adapter

Write-Output "Disable any visible network adapters not matching Primary or Backup or Heartbeat or Cluster."
Start-Sleep -Seconds 5

$AdapterNames = (Get-NetAdapter).Name

foreach ($item in $AdapterNames)

{
    if($item -notmatch "Primary" -and $item -notmatch "Backup" -and $item -notmatch "Heartbeat" -and $item -notmatch "Cluster" -and $item -notmatch "Adapter")   
    {
        Disable-NetAdapter -Name $item -Confirm:$false; Write-Output "Disabling network adpater $item.";Start-Sleep -Seconds 5
    }   
}

Start-Sleep -Seconds 5

#####################################################################################################
#Check if valid IP address has been passed for the Primary Interface. If so configure IP settings.

if($PrimaryIP -ne "0.0.0.0")
{ 
    New-NetIPAddress  -InterfaceAlias ‘Primary’ –AddressFamily IPv4 $PrimaryIP –Prefixlength $PrimaryPL –DefaultGateway $PrimaryGW; "Assign IP settings to Primary interface."
    #Check if DNS Server IP(s) passed
    if($PrimaryDNS -ne "0.0.0.0")
    {
        Set-DNSClientServerAddress –InterfaceAlias ‘Primary’ –ServerAddress $PrimaryDNS
    }   
    #Check if DNS Suffix passed
    if($PrimarySuffix -ne "")
    {
        Set-DnsClient -InterfaceAlias 'Primary' -ConnectionSpecificSuffix $PrimarySuffix
    }
}

Start-Sleep -Seconds 5

###################################################################################################
#Check if Backup Interface is installed and a valid IP address has been passed. If so configure IP settings.

if($BackupAdapterInstalled)
{
    if($BackupIP -ne "0.0.0.0")
    {
        New-NetIPAddress  -InterfaceAlias ‘Backup’ –AddressFamily IPv4 $BackupIP –Prefixlength $BackupPL; "Assign IP settings to Backup interface."
        #Check if DNS Server IP(s) passed
        Set-DNSClientServerAddress –InterfaceAlias ‘Backup’ –ServerAddress $BackupDNS
        #Check if DNS Suffix passed
        Set-DnsClient -InterfaceAlias 'Backup' -ConnectionSpecificSuffix $BackupSuffix   
    }    
}

Start-Sleep -Seconds 5

#################################################################
#Change file system label of C volume to ’System’.
Write-Output "Change file system label of C volume to ’System’."
Start-Sleep -Seconds 5
Set-Volume –DriveLetter ‘C’ –NewFileSystemLabel ‘System’
Start-Sleep -Seconds 5

###############################################################
# Create Y Volume if required
# Disk 1 is used to create Y volumeon vmware
#Before creating check that the disk is offline and partition style is raw

$YDriveFound = "no"

if((Get-Volume).DriveLetter -eq 'Y')
{
    $YDriveFound = "yes"
}
#See if y volume already exists
if($YDriveFound -eq "no")
{
    if($YDriveRequired -eq "yes")
    {
        Write-Output "Create the Y Volume."
        Start-Sleep -Seconds 5
        if(((get-disk -Number 1).PartitionStyle -eq "RAW") -and ((get-disk -Number 1).OperationalStatus -eq "Offline"))        
        {
            Initialize-Disk –Number 1 –PartitionStyle GPT
            New-Partition –DiskNumber 1 –UseMaximumSize –Driveletter Y
            Format-Volume –FileSystem NTFS –NewFileSystemLabel ‘EITS-Support-Only’ –DriveLetter Y -Confirm:$false 
            Set-Disk -Number 1 -IsOffline $False -ErrorAction SilentlyContinue
        }
        Else
        {
            Write-Output "Cannot create a Y volume."
        }
    }
    Else
    {
        Write-Output "Do not create a Y volume."
    }
}

Else
{
    Write-Output "Y volume already exists."
}

Start-Sleep -Seconds 5

##################################################################
# Change CDROM to Z
# Assume only a single CDROM
Write-Output "Change CDROM driveletter to Z."
if($drive = Get-Wmiobject -class win32_volume -filter "DriveType = 5"){Set-wmiinstance -input $drive -arguments @{DriveLetter='Z:'}}

Start-Sleep -Seconds 5

################################################################################################################################
#Set DEP to AlwaysOn
Write-Output "Set DEP to AlwaysOn."
Start-Sleep -Seconds 5
cmd /C "bcdedit.exe /set {current} nx AlwaysOn"

Start-Sleep -Seconds 5

######################################################################
#Set boot policy to legacy so that safe mode / F8 still works.
Write-Output "Set boot policy to legacy so that safe mode / F8 still works."
Start-Sleep -Seconds 5
cmd /C "bcdedit.exe /set {default} bootmenupolicy legacy"

Start-Sleep -Seconds 5

###############################################################
#Apply SNMP Configuration

switch ($Region)

{   
    'UK'
    {
        Write-Output "Apply UK snmp confiuration."; regedit /s "c:\tmp\uksnmpconfig.reg"
    }
    'US'
    {
        Write-Output "Apply US snmp confiuration."; regedit /s "c:\tmp\us-snmp-config.reg"
    }   
    'APAC'
    {
        Write-Output "Apply APAC snmp confiuration."; regedit /s "c:\tmp\apac-snmp-config.reg"
    }
    'none'
    {
        Write-Output "No snmp configuration to apply."
    }
}

Start-Sleep -Seconds 5

################################################################
#Change the password of the built in guest and DefaultAccount accounts and set passwords to expire

Write-Output "Change the password of the built in guest and DefaultAccount accounts."
Start-Sleep -Seconds 5

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$users = $adsi.Children | where {$_.SchemaClassName -eq 'user'}

#Guest account might be called Guest or SS000GU depending when script is run.
if($users.Name | Select-String "Guest"){$GuestAccountName = "Guest"; write-output "Guest account is called Guest."}
if($users.Name | Select-String "SS000GU"){$GuestAccountName = "SS000GU"; write-output "Guest account is called SS000GU."}

$pwd = Get-Password
([adsi]"WinNT://localhost/$GuestAccountName").SetPassword("$pwd")

$User1 = [ADSI]"WinNT://localhost/$GuestAccountName,user"
$User1.UserFlags.value = $User1.UserFlags.value -bxor 0x10000
$User1.CommitChanges()

$pwd2 = Get-Password
([adsi]“WinNT://localhost/DefaultAccount”).SetPassword("$pwd2")
Start-Sleep -Seconds 5

$User2 = [ADSI]"WinNT://localhost/DefaultAccount,user"
$User2.UserFlags.value = $User2.UserFlags.value -bxor 0x10000
$User2.CommitChanges()

#################################################################
#Disable the built in Administrator Account if requeted

if($DisableBuiltInAdminAcct -eq "yes")
{
    $Computername = $env:COMPUTERNAME
    $adsi = [ADSI]"WinNT://$Computername"
    $Users = $adsi.Children | where {$_.SchemaClassName -eq 'user'}
    if($users.Name | Select-String "Administrator")
    #Check that the account is called administrator. If not do not attempt to disable
    {
        Write-Output "Disable the built in Administrator Account."
        Start-Sleep -Seconds 5
        $Disabled = 0x0002
        $User =  [ADSI]"WinNT://localhost/Administrator,user"
        $User.UserFlags.value = $user.UserFlags.value -bor $Disabled
        $User.CommitChanges()
        Start-Sleep -Seconds 5
    }
Else{Write-Output "Administrator Account does not exist so do not disable."}
}

##############################################################
#Does the server need adding to a domain?
#DCs need to be >=2008R2 for the Add-Computer cmdlet to work...

if($AddToDomain -eq "yes")
{
    #Work out the FQDN of the Windows Server 2016 Member servers OU
    $OUPathPart1 = "OU=Windows Server 2016 Member Servers,OU=Servers,OU=Systems,dc="
    $OUPathPart2 = $DomainFQDN
    $OUPathPart2 = $OUPathPart2.Replace(".",",dc=")
    $OUPathComplete=$OUPathPart1 + $OUPathPart2
    
    Write-Output "Add server $NewComputerName to the $DomainFQDN domain in the OU:$OUPathComplete"
    Start-Sleep -Seconds 5
    $UserCreds=Get-Credential -Message "Enter a username amd password with permissions to add the server into the $DomainFQDN domain "
    Add-Computer -Credential $UserCreds -DomainName $DomainFQDN -OUPath $OUPathComplete -NewName $NewComputerName
}
Else
{   
    #Server not being added to a domain. See if a new name has been provided
    if($NewComputerName -ne $env:computername)   
    {
        Write-Output "Rename the server to $NewComputerName."
        Start-Sleep -Seconds 5
        Rename-Computer -NewName $NewComputerName -Force   
    }
    Else
    {
        "Do not rename the server."
    }
}

Start-Sleep -Seconds 5

##########################################################################
#Apply LocalGPO
#LGPO will error if run from the ISE as the cmd writes to stderror stream. The command still runs okay though

if($ApplyLGPO -eq "yes")
{
    Write-Output "Apply local group policy settings."
    Start-Sleep -Seconds 5
    C:\tmp\LGPO.exe /g C:\tmp\Windows2016LGPOBackup
    mkdir C:\tmp\Windows2016LGPOBackupExport
    C:\tmp\LGPO.exe /b C:\tmp\Windows2016LGPOBackupExport #can be used if required to validate that LGPO was applied correctly
    Start-Sleep -Seconds 5
}
Else{Write-Output "Do not apply local group policy settings."}

########################################################################## 