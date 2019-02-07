#Add-DNS-Entry.ps1
#Script to create A and PTR records
#Defaults to uk.experian.local

#Nigel Benton
#1.0 ready for production
#1.1 add delay to script
#1.2 increase delay



param(
$HostName,
$IP4_Address,
$ZoneName = "uk.experian.local"
)

"[Powershell] HostName is $HostName"
"[Powershell] IP4 address is $IP4_Address"
"[Powershell] Zonename is $ZoneName"

$CheckForPTR = nslookup $IP4_Address

if($CheckForPTR -match $IP4_Address )
{
"[Powershell] $IP4_Address is in reverse DNS so don't try and create PTR record."
$result = dnscmd /recordadd $ZoneName $Hostname A $IP4_Address
}

Else
{
"[Powershell] $IP4_Address is not in reverse DNS so try and create PTR record."
$result = dnscmd /recordadd $ZoneName $Hostname /CreatePTR A $IP4_Address
}

"[Powershell] $result"

if (($result -match "Command completed successfully.") -or ($result -match "DNS_ERROR_RECORD_ALREADY_EXISTS"))
{
"[Powershell] $HostName A and PTR records successfuly added to $ZoneName DNS or it already existed."
}
Else
{
"[Powershell] $HostName A or PTR records was not successfuly added to $ZoneName DNS."
exit 1
}

Start-Sleep -Seconds 600