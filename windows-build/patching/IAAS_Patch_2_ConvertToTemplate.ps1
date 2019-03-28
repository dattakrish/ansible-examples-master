###########################################################################
# Converts vm to template
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

        # Get VM object
        $template = Get-VM -Name $templateName -Location (get-folder -Name "Templates") -ErrorAction SilentlyContinue

        # Check if template exists
        If (! $template) {Write-Host "[ERROR] VM does not exist."; $exitCode = 1; continue}

        # Power off VM
        Write-Host "[INFO] Powering off $template."
        Stop-VMGuest -VM $template -Confirm:$false | Out-Null

        # Check if running
        $stopWatch = [diagnostics.stopwatch]::StartNew()
        while ($stopWatch.elapsed -lt (New-Timespan -Minutes 5)){
            If (((Get-VMGuest -VM $template).State) -eq "NotRunning"){Write-Host "[SUCCESS] Server powered off."; break}
            Start-Sleep -seconds 5
            }
        If (((Get-VMGuest -VM $template).State) -eq "Running") {
            Write-Host "[ERROR] Server still powered on after 5 minutes."
            $exitCode = 1; continue
            }

        # Convert VM to Template
        Write-Host "[INFO] Converting $template to template."
        Set-VM -VM $template -ToTemplate -Confirm:$false | Out-Null
        $template = Get-Template -Name $templateName -Location (get-folder -Name "Templates")
        If (! $template) {Write-Host "[ERROR] Template not created."; $exitCode = 1; continue}
        Write-Host "[SUCCESS] Template created."
        }
    
    #Disconnect from current vCenter
    Disconnect-VIServer -Server $vCenter -Force -Confirm:$false | Out-Null
    }

# Exit with exitCode
exit $exitCode
