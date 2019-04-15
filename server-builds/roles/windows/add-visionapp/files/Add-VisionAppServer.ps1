# This script will allow you to import a server into ASG Remote Desktop
# Example Usage:
# .\Add-VisionAppServer.ps1 -serverName UKXXXXXXXX01 -country UK -bu GTS -Service Test -domain uk.experian.local -Function Application

# Mandatory Parameters
param(
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$serverName, #Passed via Ansible template
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$country, #Passed via Ansible template
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$bu, #Passed via Ansible template
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$service, #Passed via Ansible template
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$domain, #Passed via Ansible template
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$Function #Passed via Ansible template
   )

# Set Folder Path variable
$FinalfolderPath = "Connections\$country\Automation Created\$bu\$service"

# Set Folder Path variable
$FinalParentfolderPath = "Connections\$country\Automation Created\$bu"

# Set Working directory and import ASGRD-PSAPI
$workingdir = "C:\Program Files\ASG-Remote Desktop 2019 (X64)\"

Set-Location $workingdir
[Environment]::CurrentDirectory = Get-Location -PSProvider FileSystem

$path = $workingdir + "ASGRD-PSAPI.dll"

Add-Type -path $path
[reflection.assembly]::LoadFrom($path) | Import-Module

#Connection to the Environment
Connect-RDEnvironment -Environment VisioApp2018-DSG -PassThrough

#Create Connection
$fpguid = Get-RDBaseItemId -ItemPath $FinalParentfolderPath
$fguid = Get-RDBaseItemId -ItemPath $FinalfolderPath

# If final Parent folder doesnt exist
if ($fpguid -eq "00000000-0000-0000-0000-000000000000"){
        
    # Set ParentID to Automation Created which always exists
    $ParentID = Get-RDBaseItemId -ItemPath "Connections\$country\Automation Created"
    # Create the new Folder under parent ID
    New-RDBaseItem -ParentItemId $ParentID -ItemType Folder -Text $bu -Description "Created using Powershell ASGRD-PSAPI Import script, executed by Ansible"
    # Set newGuid 
    #$newGuid = Get-RDBaseItemId -ItemPath $FinalParentfolderPath

    # If final folder doesnt exist
    if ($fguid -eq "00000000-0000-0000-0000-000000000000"){

        $ParentID = Get-RDBaseItemId -ItemPath $FinalParentfolderPath
        New-RDBaseItem -ParentItemId $ParentID -ItemType Folder -Text $service -Description "Created using Powershell ASGRD-PSAPI Import script, executed by Ansible"

        $guid = Get-RDBaseItemId -ItemPath $FinalfolderPath
        $ret = New-RDBaseItem -ParentItemId $guid -ItemType Connection -Text $serverName -Description "Created using Powershell ASGRD-PSAPI Import script, executed by Ansible"

        #Edit Connection Values
        Set-RDPropertiesConnection -ItemId $ret.ItemID -Destination $serverName -Protocol RDP

    } else { # Final Folder Exists
        $guid = Get-RDBaseItemId -ItemPath $FinalfolderPath
        $ret = New-RDBaseItem -ParentItemId $guid -ItemType Connection -Text $serverName -Description "Created using Powershell ASGRD-PSAPI Import script, executed by Ansible"

        #Edit Connection Values
        Set-RDPropertiesConnection -ItemId $ret.ItemID -Destination $serverName -Protocol RDP
    }
       
}  else { # Final Parent Folder Exists
    
    $fguid = Get-RDBaseItemId -ItemPath $FinalfolderPath
    # If final folder doesnt exist
    if ($fguid -eq "00000000-0000-0000-0000-000000000000"){

        $ParentID = Get-RDBaseItemId -ItemPath $FinalParentfolderPath
        New-RDBaseItem -ParentItemId $ParentID -ItemType Folder -Text $service -Description "Created using Powershell ASGRD-PSAPI Import script, executed by Ansible"

        $guid = Get-RDBaseItemId -ItemPath $FinalfolderPath
        $ret = New-RDBaseItem -ParentItemId $guid -ItemType Connection -Text $serverName -Description "Created using Powershell ASGRD-PSAPI Import script, executed by Ansible"

        #Edit Connection Values
        Set-RDPropertiesConnection -ItemId $ret.ItemID -Destination $serverName -Protocol RDP

    } else { # Final Folder Exists
        $guid = Get-RDBaseItemId -ItemPath $FinalfolderPath
        $ret = New-RDBaseItem -ParentItemId $guid -ItemType Connection -Text $serverName -Description "Created using Powershell ASGRD-PSAPI Import script, executed by Ansible"

        #Edit Connection Values
        Set-RDPropertiesConnection -ItemId $ret.ItemID -Destination $serverName -Protocol RDP
    }
}

# Set Final Domain name from Domain variable
switch ($domain) {
   "uk.experian.local" {$domainFinal = "EXPERIANUK"; break}
   "gdc.local" {$domainFinal = "GDC"; break}
   "ipani.uk.experian.com" {$domainFinal = "IPANIUK"; break}
   "other" {$domainFinal = "other"; break}
   default {$domainFinal = "EXPERIANUK"; break}
}

# Set IsSQL on Functionis database
switch ($Function) {
   "Application" {$IsSQL = "N"; break}
   "Database" {$IsSQL = "Y"; break}
   "Web" {$IsSQL = "N"; break}
   "Other" {$IsSQL = "N"; break}
   default {$IsSQL = "N"; break}
}

# Create server entry under SQL Domain Folder when IsSQL
if ($IsSQL -match "[Y]") {
    $guid = Get-RDBaseItemId -ItemPath "Connections\SQL Instances\$domainFinal"
    $ret = New-RDBaseItem -ParentItemId $guid -ItemType Connection -Text $serverName -Description "Created using Powershell ASGRD-PSAPI Import script, executed by Ansible"

    #Edit Connection Values
    Set-RDPropertiesConnection -ItemId $ret.ItemID -Destination $serverName -Protocol RDP
}