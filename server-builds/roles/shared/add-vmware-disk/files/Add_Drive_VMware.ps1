###########################################################################
# Add disk in VMware
# Author: Tom Meer
# Creation Date: 18/03/19
# Last Update Date: 
###########################################################################

# Read parameters
Param([string] $vCenter, [string] $serverName, [float] $size, [string] $sizeUnit)

# Write out parameters
Write-Host "[PARAMETER] Server: $serverName"
Write-Host "[PARAMETER] vCenter: $vCenter"

# Convert any MB values to GB
if ($sizeUnit -eq "MB" ) {
    Write-Host "[PARAMETER] Size in MB: $size MB"
    $size = ($size*1MB)/1GB
}

# Load PowerCLI
Set-ExecutionPolicy RemoteSigned
Import-Module VMware.VimAutomation.Core
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
Set-PowerCLIConfiguration -DefaultVIServerMode 'Multiple' -Confirm:$false | Out-Null

# Set credentials
$username = "EXPERIANUK\BladeLogicVMware"
$password = get-content 'D:\Repository\Keys\VMware\Password.txt'
$key = get-content "D:\Repository\Keys\VMware\AES.key"
$creds = New-Object -typename system.management.automation.PSCredential -ArgumentList $username, ($password | ConvertTo-SecureString -key $key)

# Function to disconnect and error
Function DisconnectAndError {
	Disconnect-VIServer * -Force:$true -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
	exit 1
}

# Connect to all vCenters
Connect-VIServer -Server $vCenter -credential $creds | Out-Null
$checkStatus = $global:DefaultVIServer
if (-not $checkStatus) {
        Write-Host "[ERROR 45] Can't connect to vCenter: $vCenter"
        exit 1
}

# Check if VM exists and only one
$server = Get-VM -Name $serverName -ErrorAction SilentlyContinue | Where-Object {$_.Folder.Name -ne "DR - Replicas"}
if (-not $server) {
	Write-Host "[ERROR 50] Could not find VM named: $serverName"
    DisconnectAndError
} elseif ($server.Count -gt 1) {
	Write-Host "[ERROR 55] More than one VM named: $serverName"
	DisconnectAndError
}

# Check available datastore storage
$datastore = $server | Get-Datastore | Sort-Object -Property @{Expression="FreeSpaceGB"; Descending=$true} | Select-Object -First 1
if ($datastore.FreeSpaceGB -lt ($size+50)) {
    Write-Host "[ERROR 60] Not enough space on the datastore: $datastore"
	DisconnectAndError
}

# Add new drive
$oldDiskCount = (Get-HardDisk $server).Count
Write-Host "[INFO] Creating new drive..."
New-HardDisk $server -CapacityGB $size
$newDiskCount = (Get-HardDisk $server).Count
if ($newDiskCount -eq $oldDiskCount) {
    Write-Host "[ERROR 70] New disk not created."
    DisconnectAndError
}
Write-Host "[SUCCESS] New disk created."

# Disconnect and exit 
Disconnect-VIServer * -Force:$true -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
exit 0