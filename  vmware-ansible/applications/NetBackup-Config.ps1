#NetBackup-Config.ps1
#
#
# Script Dependencies - NIC named "Backup" with an valid IP Address within the backup ranges that have been defined.
#
#Tested on Windows 2012 R2 in gdc.local and uk.experian.local domains.
#
#v1.0 26/02/2016 Nigel Benton
#v1.1 23/02/2017 Add test to see if netbackup agent is installed/required.
#v1.2 16/03/2017 hosts file


#Valid Backup Ranges and Gateways:
#172.30.191.254 - (172.30.184.1 to 172.30.191.253)
#172.30.195.254 - (172.30.192.1 to 172.30.195.253)
#172.30.199.254 - (172.30.196.1 to 172.30.199.253)
#172.30.203.254 - (172.30.200.1 to 172.30.203.253)
#172.30.207.254 - (172.30.204.1 to 172.30.207.253)
#172.30.211.254 - (172.30.208.1 to 172.30.211.253)
#172.30.215.254 - (172.30.212.1 to 172.30.215.253)
#172.30.219.254 - (172.30.216.1 to 172.30.219.253)
#172.30.251.254 - (172.30.248.1 to 172.30.251.253)
#172.30.255.254 - (172.30.252.1 to 172.30.255.253)
#172.30.127.254 - (172.30.124.1 to 172.30.127.253)

function Get-IPrange
{
<# 
  .SYNOPSIS  
    Get the IP addresses in a range 
  .EXAMPLE 
   Get-IPrange -start 192.168.8.2 -end 192.168.8.20 
  .EXAMPLE 
   Get-IPrange -ip 192.168.8.2 -mask 255.255.255.0 
  .EXAMPLE 
   Get-IPrange -ip 192.168.8.3 -cidr 24 
#> 
 
param 
( 
  [string]$start, 
  [string]$end, 
  [string]$ip, 
  [string]$mask, 
  [int]$cidr 
) 
 
function IP-toINT64 () { 
  param ($ip) 
 
  $octets = $ip.split(".") 
  return [int64]([int64]$octets[0]*16777216 +[int64]$octets[1]*65536 +[int64]$octets[2]*256 +[int64]$octets[3]) 
} 
 
function INT64-toIP() { 
  param ([int64]$int) 

  return (([math]::truncate($int/16777216)).tostring()+"."+([math]::truncate(($int%16777216)/65536)).tostring()+"."+([math]::truncate(($int%65536)/256)).tostring()+"."+([math]::truncate($int%256)).tostring() )
} 
 
if ($ip) {$ipaddr = [Net.IPAddress]::Parse($ip)} 
if ($cidr) {$maskaddr = [Net.IPAddress]::Parse((INT64-toIP -int ([convert]::ToInt64(("1"*$cidr+"0"*(32-$cidr)),2)))) } 
if ($mask) {$maskaddr = [Net.IPAddress]::Parse($mask)} 
if ($ip) {$networkaddr = new-object net.ipaddress ($maskaddr.address -band $ipaddr.address)} 
if ($ip) {$broadcastaddr = new-object net.ipaddress (([system.net.ipaddress]::parse("255.255.255.255").address -bxor $maskaddr.address -bor $networkaddr.address))} 
 
if ($ip) { 
  $startaddr = IP-toINT64 -ip $networkaddr.ipaddresstostring 
  $endaddr = IP-toINT64 -ip $broadcastaddr.ipaddresstostring 
} else { 
  $startaddr = IP-toINT64 -ip $start 
  $endaddr = IP-toINT64 -ip $end 
} 
 
 
for ($i = $startaddr; $i -le $endaddr; $i++) 
{ 
  INT64-toIP -int $i 
}

}


if((Get-Content -Path 'C:\Windows\System32\drivers\etc\netbackup_agent_required.txt') -ne 'no')
{


$BackupIP=""

#Check for a NIC called "Backup"
if(Get-NetAdapter -Name "Backup") {"Backup Adapter Exists"}

else {"Backup Adapter Does Not Exist. Cannot Continue."; exit 1}


#Get Backup NIC IP Address
$BackupIP = (Get-NetAdapter -Name "Backup" | Get-NetIPAddress -AddressFamily IPv4 | Select "IPAddress" -ExpandProperty IPAddress)

"Backup IP is $BackupIP"

#Make sure Backup NIC Address does not have a APIPA address or duplicate IP address on network 
if($BackupIP -eq "0.0.0.0" -or $BackupIP -like "169*"){"Backup IP Not Valid Cannot Continue."; exit 1}

#Get FQDN of backup IP
$BackupName = hostname
$BackupName = $BackupName + ".backup.local"
"Backup Name is $BackupName"


$BackupIP_And_Name = $BackupIP + "`t" + $BackupName

#Check that IP is in a valid range and determine gateway

if((get-iprange -start 172.30.184.1 -end 172.30.191.253) -match $BackupIP){ $Gateway = "172.30.191.254"; "BackupIP is in the valid range 172.30.184.1 to 172.30.191.253" }

Elseif((get-iprange -start 172.30.192.1 -end 172.30.195.253) -match $BackupIP){ $Gateway = "172.30.195.254"; "BackupIP is in the valid range 172.30.192.1 to 172.30.195.253" }

Elseif((get-iprange -start 172.30.196.1 -end 172.30.199.253) -match $BackupIP){ $Gateway = "172.30.199.254"; "BackupIP is in the valid range 172.30.196.1 to 172.30.199.253" }

Elseif((get-iprange -start 172.30.200.1 -end 172.30.203.253) -match $BackupIP){ $Gateway = "172.30.203.254"; "BackupIP is in the valid range 172.30.200.1 to 172.30.203.253 " }

Elseif((get-iprange -start 172.30.204.1 -end 172.30.207.253) -match $BackupIP){ $Gateway = "172.30.207.254"; "BackupIP is in the valid range 172.30.204.1 to 172.30.207.253" }

Elseif((get-iprange -start 172.30.208.1 -end 172.30.211.253) -match $BackupIP){ $Gateway = "172.30.211.254"; "BackupIP is in the valid range 172.30.208.1 to 172.30.211.253" }

Elseif((get-iprange -start 172.30.212.1 -end 172.30.215.253) -match $BackupIP){ $Gateway = "172.30.215.254"; "BackupIP is in the valid range 172.30.212.1 to 172.30.215.253" }

Elseif((get-iprange -start 172.30.216.1 -end 172.30.219.253) -match $BackupIP){ $Gateway = "172.30.219.254"; "BackupIP is in the valid range 172.30.216.1 to 172.30.219.253" }

Elseif((get-iprange -start 172.30.248.1 -end 172.30.251.253) -match $BackupIP){ $Gateway = "172.30.251.254"; "BackupIP is in the valid range 172.30.248.1 to 172.30.251.253" }

Elseif((get-iprange -start 172.30.252.1 -end 172.30.255.253) -match $BackupIP){ $Gateway = "172.30.255.254"; "BackupIP is in the valid range 172.30.252.1 to 172.30.255.253" }

Elseif((get-iprange -start 172.30.124.1 -end 172.30.127.253) -match $BackupIP){ $Gateway = "172.30.127.254"; "BackupIP is in the valid range 172.30.124.1 to 172.30.127.253" }
 
Else{"Backup IP is not in a valid range cannot continue"; exit 1}

"Update local hosts file with server backup address and netbackup server addresses."

$BackupIP_And_Name | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append

"# NBU NetBackup Entries" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.1   nbu-not-mast.backup.local           nbu-not-mast" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.42  nbu-not-mast3.backup.local	   nbu-not-mast3" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.43  nbu-not-mast4.backup.local	   nbu-not-mast4" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"192.168.89.89  nbu-not-mast3.uk.experian.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"192.168.89.90  nbu-not-mast4.uk.experian.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.20  nbu-not-med65a.backup.local         nbu-not-med65a" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.21  nbu-not-med65b.backup.local         nbu-not-med65b" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.22  nbu-not-med65c.backup.local         nbu-not-med65c" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.23  nbu-not-med65d.backup.local         nbu-not-med65d" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.24  nbu-not-med65e.backup.local         nbu-not-med65e" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.25  nbu-not-med65f.backup.local         nbu-not-med65f" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.26  nbu-not-med65g.backup.local         nbu-not-med65g" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.27  nbu-not-med65h.backup.local         nbu-not-med65h" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.28  nbu-not-med65i.backup.local         nbu-not-med65i" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.29  nbu-not-med65j.backup.local         nbu-not-med65j" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.30  nbu-not-med65k.backup.local         nbu-not-med65k" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"# New Netbackup Hosts" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.34  nbu-not-medfh02.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.35  nbu-not-medfh03.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.44  nbu-not-medfh04.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.46  nbu-not-medfh06.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.47  nbu-not-medfh07.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.48  nbu-not-medfh08.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.49  nbu-not-medfh09.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.36  nbu-not-medbh02.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.37  nbu-not-medbh03.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.50  nbu-not-medbh04.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.51  nbu-not-medbh05.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.52  nbu-not-medbh06.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.53  nbu-not-medbh07.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.54  nbu-not-medbh08.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.55  nbu-not-medbh09.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.56  FHDD9800-1.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.57  FHDD9800-1.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.60  BHDD9800-1.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append
"172.30.240.61  BHDD9800-1.backup.local" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding ASCII -Append


"Gateway is $Gateway"
"Configure routing"

#remove routes if they exit
if(get-netroute -DestinationPrefix "192.168.51.0/24" -ErrorAction SilentlyContinue) {remove-netroute -DestinationPrefix "192.168.51.0/24" -Confirm:$false}
if(get-netroute -DestinationPrefix "192.168.52.0/24" -ErrorAction SilentlyContinue) {remove-netroute -DestinationPrefix "192.168.52.0/24" -Confirm:$false}
if(get-netroute -DestinationPrefix "192.168.36.31/32" -ErrorAction SilentlyContinue) {remove-netroute -DestinationPrefix "192.168.36.31/32" -Confirm:$false}
if(get-netroute -DestinationPrefix "192.168.37.26/32" -ErrorAction SilentlyContinue) {remove-netroute -DestinationPrefix "192.168.37.26/32" -Confirm:$false}
if(get-netroute -DestinationPrefix "172.30.240.0/24" -ErrorAction SilentlyContinue) {remove-netroute -DestinationPrefix "172.30.240.0/24" -Confirm:$false}

#route -p add was used in netbackup "legacy" routing batch files which defaulted to a metric of 1 so this has been copied.
New-NetRoute -DestinationPrefix "192.168.51.0/24" -InterfaceAlias "Backup" -RouteMetric 1 -NextHop $Gateway
New-NetRoute -DestinationPrefix "192.168.52.0/24" -InterfaceAlias "Backup" -RouteMetric 1 -NextHop $Gateway
New-NetRoute -DestinationPrefix "192.168.36.31/32" -InterfaceAlias "Backup" -RouteMetric 1 -NextHop $Gateway
New-NetRoute -DestinationPrefix "192.168.37.26/32" -InterfaceAlias "Backup" -RouteMetric 1 -NextHop $Gateway
New-NetRoute -DestinationPrefix "172.30.240.0/24" -InterfaceAlias "Backup" -RouteMetric 1 -NextHop $Gateway

if(Test-Connection -ComputerName nbu-not-mast.backup.local -Count 30 -Quiet) {""; "Ping to nbu-not-mast.backup.local successful "}
Else{""; "Ping to nbu-not-mast.backup.local failed. Check that nbu-not-mast.backup.local is available and that network connectivity is in place"}

}

Else{write-output "Netbackup Agent not required so do not carry out any configuration."}

