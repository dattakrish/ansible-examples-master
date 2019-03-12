###########################################################################
#   SSC Automation - Windows Build - DNS Creation PS
#   Confluence:
#   Create_DNS_Record PS
#   Author: Barry Field
#   Creation Date: 07/03/19
#   Last Update Date: 08/03/19
###########################################################################

#Parameters
param ([string]$serverName, [string] $IP4Address, [string] $zoneName) 

#Look for forward and reverse records
# Start Job
$job = Start-Job -ScriptBlock {
    $reverselookup = nslookup $IP4Address
    $forwardlookup = nslookup $serverName
    }

# Wait for job to complete with timeout (in seconds)
$job | Wait-Job -Timeout 10

#based on forward result - create A record
if($forwardlookup -contains "Address: $IP4Address"){
    write-host "DNS record already exists, checking reverse lookup"
    }
Else{
    write-host "No DNS record found, attempting to create"
    $results = dnscmd /recordadd $zoneName $serverName A $IP4Address
    write-host $results
    }

#if A record creation success , create reverse lookup zone and record
if ($reverselookup -contains "Address: $IP4Address"){
write-host "DNS reverse record already exists"
    }
else {
    #replace IP with reverse zone address and set last octet of IP
    write-host "No PTR found, attempting to check zone and create"
    $reverseZoneAddress = $IP4Address -replace '^(\d+)\.(\d+)\.\d+\.(\d+)$','$3.$2.$1.in-addr.arpa'
    $ip4 = $IP4Address.Substring($IP4Address.Length -3)

    #check for reverse zone
    $checkZone = dnscmd /zoneinfo $reverseZoneAddress

    #if zone does not exist, create it
    if ($checkZone -contains "DNS_ERROR_ZONE_DOES_NOT_EXIST"){
        write-host "Zone does not exist, creating it - $reverseZoneAddress"
        $createZone = dnscmd /zoneadd $reverseZoneAddress /dsprimary /dp /domain
        #enable secure dynamic updates
	    dnscmd /config $reverseZoneAddress /allowupdate 2
            #create PTR record if succesfully created zone
		    if ($createZone -contains "Command completed successfully" ){
                write-host "Creating PTR record following successful zone creation"
			    dnscmd /recordadd $reverseZoneAddress PTR "$($serverName).$($zoneName)"
		        }
            #create PTR in existing zone
		    else {
                write-host "Zone already exists, creating PTR record"
			    dnscmd /recordadd $reverseZoneAddress $ip4 PTR "$($serverName).$($zoneName)"
                }
        }
    else {
        write-host "[Error] $serverName not added to DNS"
        }
}

#Push Sync from current Domain controller
#INFO - https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc835086(v=ws.10)

$dcSync = repadmin /syncall $env:COMPUTERNAME dc=ipani,dc=uk,dc=experian,dc=com /d /P /e /q

If ($dcSync -contains "SyncALL terminated with no errors.") {
    write-host "Sync completed succesfully."
    exit 0
    }
else { Start-Sleep -Seconds 600
    exit 0
    }
    





