###########################################################################
# Add server to SolarWinds
# Author: Tom Meer
# Creation Date: 25/01/18
# Last Update Date: 15/06/18
###########################################################################

# Read parameter
Param([string] $serverName, [String] $ipAddress)

# Load SwisPowerShell
#Install-Module -Name SwisPowerShell
Import-Module SwisPowerShell

# Initial variables
$orionHost = "10.221.72.108" # This is the IP of the Solarwinds HA DNS "solarwindsukha.uk.experian.local"
$username = "EXPERIANUK\BSASWIS"
$password = get-content 'C:\ProgramData\Experian\SSC\Password.txt'
$key = get-content "C:\ProgramData\Experian\SSC\AES.key"
$creds = New-Object -typename system.management.automation.PSCredential -ArgumentList $username, ($password | ConvertTo-SecureString -key $key)
$exitCode = 0
$count = 0

# Created SWIS credentials
#$swisCreds = Connect-Swis -Credential $creds -Hostname localhost
$swisCreds = Connect-Swis -Credential $creds -Hostname $orionHost

# Check if server exists already
$server = Get-SwisData $swisCreds "SELECT TOP 1 Uri FROM Orion.Nodes WHERE IP_Address = '$ipAddress'"
if ($server -ne $null) {
	Write-Host "[ERROR] IP address already in SolarWinds: $ipAddress"
	exit 0
}

# Core plugin Config
$CorePluginConfigurationContext = ([xml]"
<CorePluginConfigurationContext xmlns='http://schemas.solarwinds.com/2012/Orion/Core' xmlns:i='http://www.w3.org/2001/XMLSchema-instance'>
    <BulkList>
        <IpAddress>
            <Address>$ipAddress</Address>
        </IpAddress>
    </BulkList>
    <Credentials>
        <SharedCredentialInfo>
            <CredentialID>1</CredentialID>
            <CredentialID>2</CredentialID>
            <CredentialID>3</CredentialID>
            <CredentialID>4</CredentialID>
            <CredentialID>5</CredentialID>
            <Order>1</Order>
        </SharedCredentialInfo>
    </Credentials>
    <WmiRetriesCount>1</WmiRetriesCount>
    <WmiRetryIntervalMiliseconds>1000</WmiRetryIntervalMiliseconds>
</CorePluginConfigurationContext>
").DocumentElement
$CorePluginConfiguration = Invoke-SwisVerb $swisCreds Orion.Discovery CreateCorePluginConfiguration @($CorePluginConfigurationContext)

# Interface plugin Config
$InterfacesPluginConfigurationContext = ([xml]"
<InterfacesDiscoveryPluginContext xmlns='http://schemas.solarwinds.com/2008/Interfaces' 
                                  xmlns:a='http://schemas.microsoft.com/2003/10/Serialization/Arrays'>
    <AutoImportStatus>
        <a:string>Up</a:string>
        <a:string>Down</a:string>
        <a:string>Shutdown</a:string>
    </AutoImportStatus>
    <UseDefaults>false</UseDefaults>
</InterfacesDiscoveryPluginContext>
").DocumentElement
$InterfacesPluginConfiguration = Invoke-SwisVerb $swisCreds Orion.NPM.Interfaces CreateInterfacesPluginConfiguration @($InterfacesPluginConfigurationContext)
$EngineID = 7
$DeleteProfileAfterDiscoveryCompletes = "true"

# Build siscovery context from plugin config
$StartDiscoveryContext = ([xml]"
<StartDiscoveryContext xmlns='http://schemas.solarwinds.com/2012/Orion/Core' xmlns:i='http://www.w3.org/2001/XMLSchema-instance'>
    <Name>PowerShell Auto Server Discovery $([DateTime]::Now)</Name>
    <EngineId>$EngineID</EngineId>
    <JobTimeoutSeconds>3600</JobTimeoutSeconds>
    <SearchTimeoutMiliseconds>2000</SearchTimeoutMiliseconds>
    <SnmpTimeoutMiliseconds>2000</SnmpTimeoutMiliseconds>
    <SnmpRetries>1</SnmpRetries>
    <RepeatIntervalMiliseconds>1500</RepeatIntervalMiliseconds>
    <SnmpPort>161</SnmpPort>
    <HopCount>0</HopCount>
    <PreferredSnmpVersion>SNMP2c</PreferredSnmpVersion>
    <DisableIcmp>false</DisableIcmp>
    <AllowDuplicateNodes>false</AllowDuplicateNodes>
    <IsAutoImport>true</IsAutoImport>
    <IsHidden>$DeleteProfileAfterDiscoveryCompletes</IsHidden>
    <PluginConfigurations>
        <PluginConfiguration>
            <PluginConfigurationItem>$($CorePluginConfiguration.InnerXml)</PluginConfigurationItem>
            <PluginConfigurationItem>$($InterfacesPluginConfiguration.InnerXml)</PluginConfigurationItem>
        </PluginConfiguration>
    </PluginConfigurations>
</StartDiscoveryContext>
").DocumentElement

# Run disocvery
Write-Host "[INFO] Attempting to run discovery..."
$DiscoveryProfileID = (Invoke-SwisVerb $swisCreds Orion.Discovery StartDiscovery @($StartDiscoveryContext)).InnerText

# Wait until discovery has finished
Start-Sleep -s 5
$discoStatus = Get-SwisData $swisCreds "SELECT Status FROM Orion.DiscoveryProfiles WHERE ProfileID = @profileId" @{profileId = $DiscoveryProfileID}
while (($discoStatus -eq 1) -and ($count -lt 10)) {
	$count++
	Start-Sleep -s 5
	$discoStatus = Get-SwisData $swisCreds "SELECT Status FROM Orion.DiscoveryProfiles WHERE ProfileID = @profileId" @{profileId = $DiscoveryProfileID}
}

# Get Results of the discovery
$discoResult = Get-SwisData $swisCreds "SELECT Result, ResultDescription, ErrorMessage, BatchID FROM Orion.DiscoveryLogs WHERE ProfileID = @profileId" @{profileId = $DiscoveryProfileID}
Get-SwisData $swisCreds "SELECT EntityType, DisplayName, NetObjectID FROM Orion.DiscoveryLogItems WHERE BatchID = @batchId" @{batchId = $discoResult.BatchID}
$server = Get-SwisData $swisCreds "SELECT TOP 1 Uri FROM Orion.Nodes WHERE IP_Address = '$ipAddress'"
if ($server -eq $null) {
	Write-Host "[ERROR] Server discovery failed."
	exit 1
}
Write-Host "[SUCCESS] Server discovery successfull."

# Set extra properties
$serverProp = $server + "/CustomProperties";
$CustomProps= @{
    #Application = "Test Application" 
    #Imported_from_NCM = "No"
    NodeGroup = "DSG Servers"
    #SerialNumber = "Test S/N"
    }
Set-SwisObject $swisCreds -Uri $serverProp -Properties $customProps

# Exit    
exit $exitCode