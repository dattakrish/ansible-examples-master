###########################################################################
#   SSC Automation - Windows Build - DNS Creation PS
#   Confluence:
#   Create_DNS_Record PS
#   Author: Barry Field
#   Creation Date: 07/03/19
#   Last Update Date: 14/03/19
###########################################################################

#Parameters
param ([string]$serverName, [string] $IP4Address, [string] $zoneName) 

#Look for forward and reverse records
$forwardlookup = nslookup $serverName
$reverselookup = nslookup $IP4Address

#based on forward result - create A record
if($forwardlookup -contains "Address: $IP4Address"){
    write-host "DNS record already exists, checking reverse lookup"
    }
Else{
    write-host "No DNS record found, attempting to create"
    $forwardresults = dnscmd /recordadd $zoneName $serverName A $IP4Address
    }

#Forward A record creation success - continue or exit on fail.
if ($forwardresults -match "Command completed successfully") {
    write-host $forwardresults
    }

else{
    write-host "A record creation failed, exit"
    write-host $forwardresults
    exit 1
    }


#if A record creation success , create reverse lookup zone and record
if ($reverselookup -contains "Address: $IP4Address"){
write-host "DNS reverse record already exists"
exit 0
    }
else {
    #Setting zone addresses : reverse IP, replace and set last octet of IP
    write-host "No PTR found, attempting to check zones and create"
    $RevZone3 = $ip4Address -replace '^(\d+)\.(\d+)\.(\d+)\.\d+$','$3.$2.$1.in-addr.arpa'
    $RevZone2 = $IP4Address -replace '^(\d+)\.(\d+)\.\d+\.(\d+)$','$2.$1.in-addr.arpa'
    $ip4 = $IP4Address.Substring($IP4Address.Length -3)
    #Check for Reverse Zone. If zone does exists, create PTR
    $checkZone = dnscmd /zoneinfo $revZone3
    write-host $checkzone
        if ($checkZone -match "Command completed successfully."){
            write-host "Reverse zone found, creating PTR"
            $PTRresult = dnscmd /recordadd $revZone3 $ip4 PTR "$($serverName).$($zoneName)"
            #enable secure dynamic updates
            $updateresult = dnscmd /config $revZone3 /allowupdate 2
            write-host $updateresult
            write-host "Starting 5 minute delay for DNS replication"
            #Start-Sleep -Seconds 300
            exit 0
            }
        else {
            write-host "3 octet reverse zone does not exist, checking for 2 octet zone"
            $checkZone2 = dnscmd /zoneinfo $revZone2
            write-host $checkzone2
                if ($checkZone2 -match "Command completed successfully."){
                    write-host "Found 2 octet zone, creating PTR record"
                    $PTRresult = dnscmd /recordadd $revZone2 $ip4address $ip4 PTR "$($serverName).$($zoneName)"
                    #enable secure dynamic updates
                    $updateresult = dnscmd /config $revZone2 /allowupdate 2
                    write-host $updateresult
                    write-host "Starting 5 minute delay for DNS replication"
                   # Start-Sleep -Seconds 300
                    exit 0
                    }           
            }          
        else {
            write-host "No Reverse zone exists, creating zone $revZone3"
            $createZone = dnscmd /zoneadd $revZone3 /dsprimary /dp /domain
            #create PTR record if succesfully created zone
		        if ($createZone -contains "Command completed successfully"){
                    write-host "Creating PTR record following successful zone creation"
			        $PTRresult = dnscmd /recordadd $revZone3 $ip4 PTR "$($serverName).$($zoneName)"
                    #enable secure dynamic updates
                    $updateresult = dnscmd /config $revZone3 /allowupdate 2
                    write-host $updateresult
                    write-host "Starting 5 minute delay for DNS replication"
                    #Start-Sleep -Seconds 300
                    exit 0
		        }
                else {
                    write-host "Zone failed to create, exiting."
                    write-host $checkZone
                    exit 1
                }
            }
}

#Push Sync from current Domain controller
#INFO - https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc835086(v=ws.10)

#$dcSync = repadmin /syncall $env:COMPUTERNAME dc=uk,dc=experian,dc=com /d /P /e
#write-host $dcSync

#If ($dcSync -contains "SyncALL terminated with no errors.") {
#    write-host "Sync completed succesfully."
#    exit 0
#   }
#else {
#    write-host "Sync not completed, starting sleep for 600 seconds."
#write-host "Starting Delay for DNS replication"
 #   Start-Sleep -Seconds 300
  #  exit 0
#    }
    





