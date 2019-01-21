#test.ps1
#TCS
#Simulation file to test that the arguments are passed in the PS scripts from ansible
Param(
$Computer,
$Domain,
$OS,
$Location="FH"
)

"[Powershell] $Computer to be pre staged in the $Domain AD."
"[Powershell] $Computer OS is $OS."
"[Powershell] $Computer resides in $Location ."
