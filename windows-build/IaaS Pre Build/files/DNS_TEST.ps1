#DNS TESTING
$revZone3 = "150.150.10.in-addr.arpa"
dnscmd /zoneadd $revZone3 /dsprimary /dp /domain

#$ipaddress = "10.150.150.10"
#dnscmd /recordadd uk.experian.local barrytestdns /createPTR A $ipaddress

exit 0