# This script will allow you to import a server into ASG Remote Desktop
# Example Usage:
# .\Add_Server_VisionApp.ps1 -serverName UKXXXXXXXX01 -Country UK -bu GTS -Service Test -domain uk.experian.local -Function Application

param(
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$serverName, #Use Bladelogic Server NAME
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$country, #New Field required in BladeLogic?
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$bu, #Use Bladelogic Server BUSINESS_DIVISION
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$service, #New Field required in BladeLogic?
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$domain, #Use use Bladelogic Server DOMAIN, with switch statement
   [Parameter(Mandatory=$True)]
   [ValidateNotNullOrEmpty()]
   [string]$Function #Change to use Bladelogic Server BUILD_INFO_SERVER_ROLE match "Database", switch statement using $Function
   )


#$reply = Read-Host -Prompt "Is this a SQL Server?[y/n]" #Change to use Bladelogic Server BUILD_INFO_SERVER_ROLE match "Database", switch statement using $Function

$folderPath = "Connections\$country\$bu\$service"

# Set Working directory and import ASGRD-PSAPI 
#$workingdir = "C:\Program Files\ASG-Remote Desktop 2017 (X64)\"
#$workingdir = "C:\Program Files\VisionApp\"
$workingdir = "C:\Program Files\ASG-Remote Desktop 2019 (X64)\"

Set-Location $workingdir
[Environment]::CurrentDirectory = Get-Location -PSProvider FileSystem

$path = $workingdir + "ASGRD-PSAPI.dll"

Add-Type -path $path
[reflection.assembly]::LoadFrom($path) | Import-Module

#Connection to the Environment
Connect-RDEnvironment -Environment VisioApp2018-DSG -PassThrough

#Create Connection
$guid = Get-RDBaseItemId -ItemPath $folderPath

# If folder doesnt exist
if ($guid -eq "00000000-0000-0000-0000-000000000000"){
    $ParentID = Get-RDBaseItemId -ItemPath "Connections\$country\$bu"
    New-RDBaseItem -ParentItemId $ParentID -ItemType Folder -Text $service -Description "Created using Powershell ASGRD-PSAPI Import script"
    $newGuid = Get-RDBaseItemId -ItemPath $folderPath
    $ret = New-RDBaseItem -ParentItemId $newGuid -ItemType Connection -Text $serverName -Description "Imported via powershell script"

    #Edit Connection Values
    Set-RDPropertiesConnection -ItemId $ret.ItemID -Destination $serverName -Protocol RDP
} else { #Folder Exists
    $guid = Get-RDBaseItemId -ItemPath $folderPath
    $ret = New-RDBaseItem -ParentItemId $guid -ItemType Connection -Text $serverName -Description "Imported via powershell script"

    #Edit Connection Values
    Set-RDPropertiesConnection -ItemId $ret.ItemID -Destination $serverName -Protocol RDP
}

switch ($domain) {
   "uk.experian.local" {$domainFinal = "EXPERIANUK"; break}
   "gdc.local" {$domainFinal = "GDC"; break}
   "ipani.uk.experian.com" {$domainFinal = "IPANIUK"; break}
   "other" {$domainFinal = "other"; break}
   default {$domainFinal = "EXPERIANUK"; break}
}

switch ($Function) {
   "Application" {$IsSQL = "N"; break}
   "Database" {$IsSQL = "Y"; break}
   "Web" {$IsSQL = "N"; break}
   "Other" {$IsSQL = "N"; break}
   default {$IsSQL = "N"; break}
}

if ($IsSQL -match "[Y]") {
    $guid = Get-RDBaseItemId -ItemPath "Connections\SQL Instances\$domainFinal"
    $ret = New-RDBaseItem -ParentItemId $guid -ItemType Connection -Text $serverName -Description "Imported via powershell script"
}