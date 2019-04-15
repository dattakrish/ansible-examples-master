###########################################################################
# Check VM Customisation Status
# Author: Tom Meer
# Creation Date: 20/03/19
# Last Update Date: 12/04/19
###########################################################################

# Read parameters
Param([string] $vCenter, [string] $serverName, [string] $domain, [string] $backupTag, [string] $serverRole, [string] $vmFolder, [string] $datacenter)

# Write out parameters
Write-Host "[PARAMETER] Server: $serverName"
Write-Host "[PARAMETER] vCenter: $vCenter"
Write-Host "[PARAMETER] Datacenter: $datacenter"
Write-Host "[PARAMETER] Domain: $domain"
Write-Host "[PARAMETER] Role: $serverRole"
Write-Host "[PARAMETER] Folder: $vmFolder"

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

# Connect to vCenter
Connect-VIServer -Server $vCenter -credential $creds | Out-Null
$checkStatus = $global:DefaultVIServer
if (-not $checkStatus) {
        Write-Host "[ERROR] Can't connect to vCenter: $vCenter"
        exit 1
}

# Check if VM exists and only one
$server = Get-VM -Name $serverName -ErrorAction SilentlyContinue | Where-Object {$_.Folder.Name -ne "DR - Replicas"}
if (-not $server) {
	Write-Host "[ERROR] Could not find VM named: $serverName"
    DisconnectAndError
} elseif ($server.Count -gt 1) {
	Write-Host "[ERROR] More than one VM named: $serverName"
	DisconnectAndError
}

# Wait for OS customisation to complete
$customisationStatus = Get-VIEvent $server | Where-Object {($_.FullFormattedMessage -like "*Customization of VM $serverName succeeded*")}
$count = 0
while ((! $customisationStatus) -and ($count -lt 60)) {
    $count++
    Write-Host "[INFO] Waiting for VM to finish customisation..."
    Start-Sleep -s 30
    $customisationStatus = Get-VIEvent $server | Where-Object {($_.FullFormattedMessage -like "*Customization of VM $serverName succeeded*")}
}
if (! $customisationStatus) {
    Write-Host "[ERROR] VM not finished customisation in less han an hour: $serverName"
    DisconnectAndError
} else {
    Write-Host "[SUCCESS] VM customisation complete: $serverName"
}

# Check if DNS/Domain has been assigned correctly
if ($domain -ne "workgroup") {
    $dnsName = (Get-VM $server).ExtensionData.Guest.Hostname
    $count = 0
    while (($dnsName -ne "$serverName.$domain") -and ($count -lt 20)) {
	    $count++
	    Start-Sleep -s 30
	    $dnsName = (Get-VM $server).ExtensionData.Guest.Hostname
    }
    if ($dnsName -ne "$serverName.$domain") {
	    Write-Host "[ERROR] DNS name has not been assigned correctly: $dnsName"
	    DisconnectAndError
    } else {
        Write-Host "[SUCCESS] DNS name: $dnsName"
    }
}

# Assign backup tag to VM if database and Synergy
if ($serverRole -eq "Database") {
    if ($vCenter -eq "ukfhpcbvcs02.uk.experian.local" -Or $vCenter -eq "ukblpcbvcs02.uk.experian.local") {
        $tag = Get-Tag -Name $backupTag
        $server | New-TagAssignment -Tag $tag
    }
}

# Make sure folder exists and move vm to it
if ($vmFolder) {
	$vmFolder = $vmFolder.Trim("\")
	$folders = $vmFolder.Split("\\")
    cd vi:\$datacenter\vm
	foreach ($folder in $folders) {
	    if (-Not (Test-Path $folder)) {
            Write-Host "[INFO] Creating new folder: $folder"
		    New-Folder -Name $folder | Out-Null
		}
	    cd $folder
	}
    cd ..
	$finalFolder = Get-Folder "$folder" | Select-Object -First 1
	Write-Host "[INFO] Moving VM to folder: $finalFolder"
    Move-VM -VM $server -InventoryLocation $finalFolder | Out-Null
}

# Disconnect and exit 
Disconnect-VIServer * -Force:$true -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
exit 0