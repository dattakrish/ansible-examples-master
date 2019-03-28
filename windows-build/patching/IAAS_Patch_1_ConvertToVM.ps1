###########################################################################
# Converts template to vm
# Author: Tom Meer
# Creation Date: 30/08/17
# Last Update Date: 04/02/19
###########################################################################

# Read Parameters
param ([array] $templates)

# Initial Variables
$vCenterList = @{"ukfhpvbvcs01.uk.experian.local" = "Template-FH"; "ukblpvbvcs01.uk.experian.local" = "Template-BL"; "ukfhpcbvcs02.uk.experian.local" = "Synergy-FH"; "ukblpcbvcs02.uk.experian.local" = "Synergy-BL"}
$exitCode = 0

# Load PowerCLI
Import-Module VMware.VimAutomation.Core

# Loop through vCenters
foreach ($vCenter in $vCenterList.keys) {
    # Connect to vCenter using encyrpted credentials
    Write-Host "[INFO] Connecting to vCenter $vCenter."
    $password = get-content 'D:\Repository\Keys\VMware\Password.txt'
    $key = get-content "D:\Repository\Keys\VMware\AES.key"
    $username = "EXPERIANUK\BladeLogicVMware"
    $creds = New-Object -typename system.management.automation.PSCredential -ArgumentList $username, ($password | ConvertTo-SecureString -key $key)
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
    Connect-VIServer -Server $vCenter -credential $creds | Out-Null

    # Loop through list of templates
    foreach ($templateName in $templates) {
        # Check for other vCenters
        $templateSuffix = $vCenterList.Get_Item("$vCenter")
        If ($templateName -like "*$templateSuffix") {Write-Host "[INFO] Working on template: $templateName"}
        Else {continue}

        # If synergy template remove "Synergy" from name
        If ($templateName -like "*Synergy*") {
            $templateName = $templateName -replace "Synergy-"
            Write-Host "[INFO] Synergy template name: $templateName"
        }

        # Get template object
        $template = Get-Template -Name $templateName -Location (get-folder -Name "Templates") -ErrorAction SilentlyContinue

        # Check if template exists
        If (! $template) {Write-Host "[ERROR] Template does not exist."; $exitCode = 1; continue}

        # Convert Template to VM
        Write-Host "[INFO] Converting $template to VM."
        Set-Template -Template $template -ToVM  | Out-Null
        $template = Get-VM -Name $templateName -Location (get-folder -Name "Templates")
        Write-Host "[INFO] Disconnecting any attched ISO files."
        Get-CDDrive -VM $template | Set-CDDrive -NoMedia -Confirm:$false | Out-Null

        # Clone VM to archive folder
        Write-Host "[INFO] Creating backup clone..."
        $datastore = Get-Datastore -VM $template
        $date = Get-Date –f "yyyy-MM-dd"
        $backupCheck = Get-Template -Name "$template $date" -Location (get-folder -Name "Previous Versions") -ErrorAction SilentlyContinue
        If ($backupCheck) {Write-Host "[INFO] $template $date already exists, deleting..."; Remove-Template -Template $backupCheck -DeletePermanently -Confirm:$false}
        New-Template -VM $template -Name "$template $date" -Datastore $datastore -Location (get-folder -Name "Previous Versions") | Out-Null

        # Check for backup
        $backup = Get-Template -Name "$template $date" -Location (get-folder -Name "Previous Versions") -ErrorAction SilentlyContinue
        If (! $backup) {
            Write-Host "[ERROR] Backup not created, regressing." 
            Set-VM -VM $template -ToTemplate -Confirm:$false | Out-Null
            $exitCode = 1; continue
            }
        Else {Write-Host "[SUCCESS] Backup created."}

        # If more than 2 backups, delete oldest one
        $backupList = Get-Template -Name "$template *" -Location (get-folder -Name "Previous Versions") -ErrorAction SilentlyContinue | Sort-Object Name
            If ((($backupList).count) -gt 2) {
            $oldestBackup = $backupList | Select-Object -first 1
            Write-Host "[INFO] More than 2 backups detected, deleting oldest: $oldestBackup" 
            Remove-Template -Template $oldestBackup -DeletePermanently -Confirm:$false | Out-Null
            }

        # Power on VM
        Write-Host "[INFO] Powering on $template."
        Start-VM -VM $template | Out-Null

        # Check if running
        $stopWatch = [diagnostics.stopwatch]::StartNew()
        while ($stopWatch.elapsed -lt (New-Timespan -Minutes 5)){
            If (((Get-VMGuest -VM $template).State) -eq "Running"){Write-Host "[SUCCESS] Server powered on."; break}
            Start-Sleep -seconds 5
            }
        If (((Get-VMGuest -VM $template).State) -eq "NotRunning") {
            Write-Host "[ERROR] Server not powered on, regressing."
            Set-VM -VM $template -ToTemplate -Confirm:$false | Out-Null
            $exitCode = 1; continue
            }
        }
    
    #Disconnect from current vCenter
    Disconnect-VIServer -Server $vCenter -Force -Confirm:$false | Out-Null
    }

# Exit with exitCode
exit $exitCode
