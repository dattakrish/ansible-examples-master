## SQL Service Account Creation

param ([string]$installTemplate, [string]$sqlCollation, [string]$businessunit, [string]$supportgroup)

#ansible_ad account files
$KeyFile = "C:\tmp\SQL\Keys\ansiblead.key"
$txtFile = "C:\tmp\SQL\Keys\ansiblead.txt"
$key1 = get-content $keyfile

#Load AD Module
write-host "Importing ActiveDirectory PS module"
import-module ActiveDirectory

#set username, description and office
$usernamesql = "$env:computername"+"SQL"
$usernameagt = "$env:computername"+"AGT"
$Descriptionsql = "SQL Server Service account for $Computername"
$Descriptionagt = "SQL Agent Service account for $Computername"
$office = "Owner = $businessunit - $supportgroup"

#set domain
$getdomain = get-addomain | select DNSroot
$domain= $getdomain.dnsroot
$username = "$domain\ansible_ad"

#set ou
if ($domain -eq "uk.experian.local"){
    $ou = "ou=Service Accounts,ou=accounts,dc=uk,dc=experian,dc=local"
    }
elseif ($domain -eq "gdc.local"){
    $ou = "ou=Service Accounts,ou=accounts,dc=gdc,dc=local"
    }
else{
    $ou = "ou=Service Accounts,dc=ipani,dc=uk,dc=experian,dc=com"
    }

#region Generate-Random-Password-Function
function New-SWRandomPassword {
    [CmdletBinding(DefaultParameterSetName='FixedLength',ConfirmImpact='None')]
 [OutputType([String])]
 Param
 (
     # Specifies minimum password length
     [Parameter(Mandatory=$false,
                ParameterSetName='RandomLength')]
     [ValidateScript({$_ -gt 0})]
     [Alias('Min')] 
     [int]$MinPasswordLength = 8,
     
     # Specifies maximum password length
     [Parameter(Mandatory=$false,
                ParameterSetName='RandomLength')]
     [ValidateScript({
             if($_ -ge $MinPasswordLength){$true}
             else{Throw 'Max value cannot be lesser than min value.'}})]
     [Alias('Max')]
     [int]$MaxPasswordLength = 12,

     # Specifies a fixed password length
     [Parameter(Mandatory=$false,
                ParameterSetName='FixedLength')]
     [ValidateRange(1,2147483647)]
     [int]$PasswordLength = 8,
     
     # Specifies an array of strings containing charactergroups from which the password will be generated.
     # At least one char from each group (string) will be used.
     [String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '1234567890'),
     #[String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '1234567890', '!"#%&'),

     # Specifies a string containing a character group from which the first character in the password will be generated.
     # Useful for systems which requires first char in password to be alphabetic.
     [String] $FirstChar,
     
     # Specifies number of passwords to generate.
     [ValidateRange(1,2147483647)]
     [int]$Count = 1
 )
 Begin {
     Function Get-Seed{
         # Generate a seed for randomization
         $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
         $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
         $Random.GetBytes($RandomBytes)
         [BitConverter]::ToUInt32($RandomBytes, 0)
     }
 }
 Process {
     For($iteration = 1;$iteration -le $Count; $iteration++){
         $Password = @{}
         # Create char arrays containing groups of possible chars
         [char[][]]$CharGroups = $InputStrings

         # Create char array containing all chars
         $AllChars = $CharGroups | ForEach-Object {[Char[]]$_}

         # Set password length
         if($PSCmdlet.ParameterSetName -eq 'RandomLength')
         {
             if($MinPasswordLength -eq $MaxPasswordLength) {
                 # If password length is set, use set length
                 $PasswordLength = $MinPasswordLength
             }
             else {
                 # Otherwise randomize password length
                 $PasswordLength = ((Get-Seed) % ($MaxPasswordLength + 1 - $MinPasswordLength)) + $MinPasswordLength
             }
         }

         # If FirstChar is defined, randomize first char in password from that string.
         if($PSBoundParameters.ContainsKey('FirstChar')){
             $Password.Add(0,$FirstChar[((Get-Seed) % $FirstChar.Length)])
         }
         # Randomize one char from each group
         Foreach($Group in $CharGroups) {
             if($Password.Count -lt $PasswordLength) {
                 $Index = Get-Seed
                 While ($Password.ContainsKey($Index)){
                     $Index = Get-Seed                        
                 }
                 $Password.Add($Index,$Group[((Get-Seed) % $Group.Count)])
             }
         }

         # Fill out with chars from $AllChars
         for($i=$Password.Count;$i -lt $PasswordLength;$i++) {
             $Index = Get-Seed
             While ($Password.ContainsKey($Index)){
                 $Index = Get-Seed                        
             }
             $Password.Add($Index,$AllChars[((Get-Seed) % $AllChars.Count)])
         }
         Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
     }
 }
}

#endregion Generate-Random-Password-Function

#Create-AD-User-Accounts for SQL Service and SQL Agent Service
$RndPwd1 = New-SWRandomPassword -PasswordLength 12
$PWD1 = ConvertTo-SecureString $RndPwd1 -AsPlainText -Force
$RndPwd2 = New-SWRandomPassword -PasswordLength 12
$PWD2 = ConvertTo-SecureString $RndPwd2 -AsPlainText -Force

#create AD accounts
write-host "Attempting to create new $usernamesql and $usernameagt in $domain - $ou"
$mycreds = New-Object -typename system.management.automation.PSCredential -ArgumentList $username, (get-content $txtfile | ConvertTo-SecureString -key $Key1)
New-ADUser -credential $mycreds -SamAccountName $usernamesql -name $usernamesql -DisplayName $usernamesql -AccountPassword $PWD1 -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $false -Path $ou -Description $Descriptionsql -office $office -PasswordNeverExpires $true
New-ADUser -credential $mycreds -SamAccountName $usernameagt -name $usernameagt -DisplayName $usernameagt -AccountPassword $PWD2 -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $false -Path $ou -Description $Descriptionagt -office $office -PasswordNeverExpires $true


#region Modify-Unattended-Install-File
write-host "Attempting to modify INI file"
if ($domain -eq "uk.experian.local") {
    (get-content $installtemplate) | foreach-object {$_ -replace ';SQLSYSADMINACCOUNTS="EXPERIANUK', 'SQLSYSADMINACCOUNTS="EXPERIANUK' -replace "@domain@", "experianuk" -replace "@svcSQLAccount@", "$usernamesql" -replace "@svcAGTAccount@", "$usernameagt" -replace "@svcSQLpassword@", "$RndPwd1" -replace "@svcSQLAgentpassword@", "$RndPwd2" -replace "@sqlCollation@", "$sqlcollation"} | set-content $installtemplate -Force
    }
Elseif ($domain -eq "gdc.local") {
    (get-content $installtemplate) | foreach-object {$_ -replace ';SQLSYSADMINACCOUNTS="GDC', 'SQLSYSADMINACCOUNTS="GDC' -replace "@domain@", "gdc" -replace "@svcSQLAccount@", "$usernamesql" -replace "@svcAGTAccount@", "$usernameagt" -replace "@svcSQLpassword@", "$RndPwd1" -replace "@svcSQLAgentpassword@", "$RndPwd2" -replace "@sqlCollation@", "$sqlcollation"} | set-content $installtemplate -Force
    }
Else {
    (get-content $installtemplate) | foreach-object {$_ -replace ';SQLSYSADMINACCOUNTS="IPANIUK', 'SQLSYSADMINACCOUNTS="IPANIUK' -replace "@domain@", "ipaniuk" -replace "@svcSQLAccount@", "$usernamesql" -replace "@svcAGTAccount@", "$usernameagt" -replace "@svcSQLpassword@", "$RndPwd1" -replace "@svcSQLAgentpassword@", "$RndPwd2" -replace "@sqlCollation@", "$sqlcollation"} | set-content $installtemplate -Force
    }

exit 0