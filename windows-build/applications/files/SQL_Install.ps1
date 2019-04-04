###########################################################################
#   SSC Automation - Windows Build - SQL Install
#   Confluence:
#   Author: Barry Field
#   Creation Date: 29/01/19
#   Last Update Date: 27/03/19
###########################################################################

#Script tasks:
# - Create local sqladmin account on host
# - generate random passwords and create sql agent adn sql service domain accounts
# - amend local security policy to allow local login for new accounts
# - edit INI file for installation with new accounts + sql collation
# - start installation of SQL

# Params
param ([string]$cmdFile, [string]$installTemplate, [string]$sqlCollation, [string]$workingDir)

$sqladmin_key = "C:\tmp\SQL\Keys\SQLAdmin.key" #key file location for sqladmin pw
$sqladmin_pw = "C:\tmp\SQL\Keys\Password.txt" #pw file location for sqladmin pw
$KeyFile = "C:\tmp\SQL\Keys\ansiblead.key" #Take input from SNOW
$txtFile = "C:\tmp\SQL\Keys\ansiblead.txt" #Take input from SNOW
$key1 = get-content $keyfile


#region Create-Local-SQLAdmin-Account
$computername = $env:computername
$username = 'sqladmin'
$desc = 'SQL Admin Account'
$key = get-content $sqladmin_key
$password = get-content $sqladmin_pw | ConvertTo-SecureString -key $Key
$SQLPassword = (New-Object PSCredential "user",$Password).GetNetworkCredential().Password
write-host "Attempting to create 'sqladmin' account and add to local administrators."

$computer = [ADSI]"WinNT://$computername,computer"
$user = $computer.Create("user", $username)
$user.SetPassword($SQLPassword)
$user.Setinfo()
$user.description = $desc
$user.setinfo()
$user.UserFlags = 65536
$user.SetInfo()
$group = [ADSI]("WinNT://$computername/administrators,group")
$group.add("WinNT://$username,user")
#endregion Create-Local-SQLAdmin-Account

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

#region Configure-Local-Security-Policy
function Add-LoginToLocalPrivilege {
    <#
            .SYNOPSIS
    Adds the provided login to the local security privilege that is chosen. Must be run as Administrator in UAC mode.
    Returns a boolean $true if it was successful, $false if it was not.
    
    .DESCRIPTION
    Uses the built in secedit.exe to export the current configuration then re-import
    the new configuration with the provided login added to the appropriate privilege.
    
    The pipeline object must be passed in a DOMAIN\User format as string.
    
    This function supports the -WhatIf, -Confirm, and -Verbose switches.
    
    .PARAMETER DomainAccount
    Value passed as a DOMAIN\Account format.
    
    .PARAMETER Domain 
    Domain of the account - can be local account by specifying local computer name.
    Must be used in conjunction with Account.
    
    .PARAMETER Account
    Username of the account you want added to that privilege
    Must be used in conjunction with Domain
    
    .PARAMETER Privilege
    The name of the privilege you want to be added.
    
    This must be one in the following list:
    SeManageVolumePrivilege
    SeLockMemoryPrivilege
    
    .PARAMETER TemporaryFolderPath
    The folder path where the secedit exports and imports will reside. 
    
    The default if this parameter is not provided is $env:USERPROFILE
    
    .EXAMPLE
    Add-LoginToLocalPrivilege -Domain "NEIER" -Account "Kyle" -Privilege "SeManageVolumePrivilege"
    
    Using full parameter names
    
    .EXAMPLE
    Add-LoginToLocalPrivilege "NEIER\Kyle" "SeLockMemoryPrivilege"
    
    Using Positional parameters only allowed when passing DomainAccount together, not independently.
    
    .EXAMPLE
    Add-LoginToLocalPrivilege "NEIER\Kyle" "SeLockMemoryPrivilege" -Verbose
    
    This function supports the verbose switch. Will provide to you several 
    text cues as part of the execution to the console. Will not output the text, only presents to console.
    
    .EXAMPLE
    ("NEIER\Kyle", "NEIER\Stephanie") | Add-LoginToLocalPrivilege -Privilege "SeManageVolumePrivilege" -Verbose
    
    Passing array of DOMAIN\User as pipeline parameter with -v switch for verbose logging. Only "Domain\Account"
    can be passed through pipeline. You cannot use the Domain and Account parameters when using the pipeline.
    
    .NOTES
    The temporary files should be removed at the end of the script. 
    
    If there is error - two files may remain in the $TemporaryFolderPath (default $env:USERPFORILE)
    UserRightsAsTheyExist.inf
    ApplyUserRights.inf
    
    These should be deleted if they exist, but will be overwritten if this is run again.
    
    Author:    Kyle Neier
    Blog: http://sqldbamusings.blogspot.com
    Twitter: Kyle_Neier
    #>
    
        #Specify the default parameterset
        [CmdletBinding(DefaultParametersetName="JointNames", SupportsShouldProcess=$true, ConfirmImpact='High')]
    param
        (
    [parameter(
    Mandatory=$true, 
    Position=0,
    ParameterSetName="SplitNames")]
    [string] $Domain,
    
    [parameter(
    Mandatory=$true, 
    Position=1,
    ParameterSetName="SplitNames"
                )]
    [string] $Account,
    
    [parameter(
    Mandatory=$true, 
    Position=0,
    ParameterSetName="JointNames",
    ValueFromPipeline= $true
                )]
    [string] $DomainAccount,
    
    [parameter(Mandatory=$true, Position=2)]
    [ValidateSet("SeManageVolumePrivilege", "SeLockMemoryPrivilege", "SeDebugPrivilege")]
    [string] $Privilege,
    
    [parameter(Mandatory=$false, Position=3)]
    [string] $TemporaryFolderPath = $env:USERPROFILE
            
    )
    
    #Determine which parameter set was used
        switch ($PsCmdlet.ParameterSetName)
    {
    "SplitNames"
            { 
    #If SplitNames was used, combine the names into a single string
                Write-Verbose "Domain and Account provided - combining for rest of script."
                $DomainAccount = "$Domain`\$Account"
            }
    "JointNames"
            {
    Write-Verbose "Domain\Account combination provided."
                #Need to do nothing more, the parameter passed is sufficient.
            }
    }
    
    #Created simple function here so I didn't have to re-type these commands
        function Remove-TempFiles
        {
    #Evaluate whether the ApplyUserRights.inf file exists
            if(Test-Path $TemporaryFolderPath\ApplyUserRights.inf)
    {
    #Remove it if it does.
                Write-Verbose "Removing $TemporaryFolderPath`\ApplyUserRights.inf"
                Remove-Item $TemporaryFolderPath\ApplyUserRights.inf -Force -WhatIf:$false
            }
    
    #Evaluate whether the UserRightsAsTheyExists.inf file exists
            if(Test-Path $TemporaryFolderPath\UserRightsAsTheyExist.inf)
    {
    #Remove it if it does.
                Write-Verbose "Removing $TemporaryFolderPath\UserRightsAsTheyExist.inf"
                Remove-Item $TemporaryFolderPath\UserRightsAsTheyExist.inf -Force -WhatIf:$false
            }
    }
    
    Write-Verbose "Adding $DomainAccount to $Privilege"
    
        Write-Verbose "Verifying that export file does not exist."
        #Clean Up any files that may be hanging around.
        Remove-TempFiles
        
    Write-Verbose "Executing secedit and sending to $TemporaryFolderPath"
        #Use secedit (built in command in windows) to export current User Rights Assignment
        $SeceditResults = secedit /export /areas USER_RIGHTS /cfg $TemporaryFolderPath\UserRightsAsTheyExist.inf
    
    #Make certain export was successful
        if($SeceditResults[$SeceditResults.Count-2] -eq "The task has completed successfully.")
    {
    
    Write-Verbose "Secedit export was successful, proceeding to re-import"
            #Save out the header of the file to be imported
            
    Write-Verbose "Save out header for $TemporaryFolderPath`\ApplyUserRights.inf"
            
    "[Unicode]
    Unicode=yes
    [Version]
    signature=`"`$CHICAGO`$`"
    Revision=1
    [Privilege Rights]" | Out-File $TemporaryFolderPath\ApplyUserRights.inf -Force -WhatIf:$false
                                        
    #Bring the exported config file in as an array
            Write-Verbose "Importing the exported secedit file."
            $SecurityPolicyExport = Get-Content $TemporaryFolderPath\UserRightsAsTheyExist.inf
    
            #enumerate over each of these files, looking for the Perform Volume Maintenance Tasks privilege
            [Boolean]$isFound = $false
            foreach($line in $SecurityPolicyExport)
    {
    if($line -like "$Privilege`*")
    {
    Write-Verbose "Line with the $Privilege found in export, appending $DomainAccount to it"
                                #Add the current domain\user to the list
                                $line = $line + ",$DomainAccount"
                                #output line, with all old + new accounts to re-import
                                $line | Out-File $TemporaryFolderPath\ApplyUserRights.inf -Append -WhatIf:$false
                                
    $isFound = $true
                }
    }
    
    if($isFound -eq $false)
    {
    #If the particular command we are looking for can't be found, create it to be imported.
                Write-Verbose "No line found for $Privilege - Adding new line for $DomainAccount"
                "$Privilege`=$DomainAccount" | Out-File $TemporaryFolderPath\ApplyUserRights.inf -Append -WhatIf:$false
            }
    
    #Import the new .inf into the local security policy.
            if ($pscmdlet.ShouldProcess($DomainAccount, "Account be added to Local Security with $Privilege privilege?"))
    {
    # yes, Run the import:
                Write-Verbose "Importing $TemporaryfolderPath\ApplyUserRighs.inf"
                $SeceditApplyResults = SECEDIT /configure /db secedit.sdb /cfg $TemporaryFolderPath\ApplyUserRights.inf
    
    #Verify that update was successful (string reading, blegh.)
                if($SeceditApplyResults[$SeceditApplyResults.Count-2] -eq "The task has completed successfully.")
    {
    #Success, return true
                    Write-Verbose "Import was successful."
                    Write-Output $true
                }
    else
                {
    #Import failed for some reason
                    Write-Verbose "Import from $TemporaryFolderPath\ApplyUserRights.inf failed."
                    Write-Output $false
                    Write-Error -Message "The import from$TemporaryFolderPath\ApplyUserRights using secedit failed. Full Text Below:
    $SeceditApplyResults)"
                }
    }
    }
    else
        {
    #Export failed for some reason.
            Write-Verbose "Export to $TemporaryFolderPath\UserRightsAsTheyExist.inf failed."
            Write-Output $false
            Write-Error -Message "The export to $TemporaryFolderPath\UserRightsAsTheyExist.inf from secedit failed. Full Text Below:
    $SeceditResults)"
            
    }
    
    Write-Verbose "Cleaning up temporary files that were created."
        #Delete the two temp files we created.
        Remove-TempFiles
        
    }
    
    #endregion Configure-Local-Security-Policy

#region Create-AD-User-Accounts for SQL Service and SQL Agent Service
$RndPwd1 = New-SWRandomPassword -PasswordLength 12
$PWD1 = ConvertTo-SecureString $RndPwd1 -AsPlainText -Force

$RndPwd2 = New-SWRandomPassword -PasswordLength 12
$PWD2 = ConvertTo-SecureString $RndPwd2 -AsPlainText -Force

$usernamesql = "$env:computername"+"SQL"
$usernameagt = "$env:computername"+"AGT"
$Descriptionsql = "SQL Server Service account for $Computername"
$Descriptionagt = "SQL Agent Service account for $Computername"
write-host "Setting account names $usernamesql and $usernameagt"

#Load AD Module
write-host "Importing ActiveDirectory PS module"
import-module ActiveDirectory

#Identify Domain and create relevent Domain Accounts
write-host "Attempting to get domain information and create new AD users"
if (Get-ADDomain | Select -property DNSRoot | where {$_.DNSRoot -like "uk.experian.local"}) {
    $username = "experianuk\ansible_ad"
    write-host "Attempting to create new AD users in ExperianUK with $username"
    $mycreds = New-Object -typename system.management.automation.PSCredential -ArgumentList $username, (get-content $txtfile | ConvertTo-SecureString -key $Key1)
    $accresult = New-ADUser -credential $mycreds -SamAccountName $usernamesql -name $usernamesql -DisplayName $usernamesql -AccountPassword $PWD1 -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $false -Path "ou=Service Accounts,ou=accounts,dc=uk,dc=experian,dc=com" -Description $Descriptionsql -PasswordNeverExpires $true
    $accresult1 = New-ADUser -credential $mycreds -SamAccountName $usernameagt -name $usernameagt -DisplayName $usernameagt -AccountPassword $PWD2 -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $false -Path "ou=Service Accounts,ou=accounts,dc=uk,dc=experian,dc=com" -Description $Descriptionagt -PasswordNeverExpires $true
    Add-LoginToLocalPrivilege "experianuk\$usernamesql" "SeLockMemoryPrivilege"
    Add-LoginToLocalPrivilege "Administrators" "SeDebugPrivilege"
    Add-LoginToLocalPrivilege "experianuk\$usernamesql" "SeManageVolumePrivilege"
    $accresult
    $accresult1
    }

Elseif (Get-ADDomain | Select -property DNSRoot | where {$_.DNSRoot -like "gdc.local"}) {
    $username = "gdc\ansible_ad"
    write-host "Attempting to create new AD users in GDC with $username"
    $mycreds = New-Object -typename system.management.automation.PSCredential -ArgumentList $username, (get-content $txtfile | ConvertTo-SecureString -key $Key1)
    $accresult = New-ADUser -credential $mycreds -SamAccountName $usernamesql -name $usernamesql -DisplayName $usernamesql -AccountPassword $PWD1 -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $false -Path "ou=Service Accounts,ou=accounts,dc=gdc,dc=local" -Description $Descriptionsql -PasswordNeverExpires $true
    $accresult1 = New-ADUser -credential $mycreds -SamAccountName $usernameagt -name $usernameagt -DisplayName $usernameagt -AccountPassword $PWD2 -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $false -Path "ou=Service Accounts,ou=accounts,dc=gdc,dc=local" -Description $Descriptionagt -PasswordNeverExpires $true
    Add-LoginToLocalPrivilege "gdc\$usernamesql" "SeLockMemoryPrivilege"
    Add-LoginToLocalPrivilege "Administrators" "SeDebugPrivilege"
    Add-LoginToLocalPrivilege "gdc\$usernamesql" "SeManageVolumePrivilege"
    $accresult
    $accresult1
    }

Else {(Get-ADDomain | Select -property DNSRoot | where {$_.DNSRoot -like "ipani.uk.experian.com"})
    $username = "ipaniuk\ansible_ad"
    write-host "Attempting to create new AD users in IPANI with $username"
    $mycreds = New-Object -typename system.management.automation.PSCredential -ArgumentList $username, (get-content $txtfile | ConvertTo-SecureString -key $Key1)
    $accresult = New-ADUser -credential $mycreds -SamAccountName $usernamesql -name $usernamesql -DisplayName $usernamesql -AccountPassword $PWD1 -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $false -Path "ou=Service Accounts,dc=ipani,dc=uk,dc=experian,dc=com" -Description $Descriptionsql -PasswordNeverExpires $true
    $accresult1 = New-ADUser -credential $mycreds -SamAccountName $usernameagt -name $usernameagt -DisplayName $usernameagt -AccountPassword $PWD2 -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $false -Path "ou=Service Accounts,dc=ipani,dc=uk,dc=experian,dc=com" -Description $Descriptionagt -PasswordNeverExpires $true
    Add-LoginToLocalPrivilege "ipaniuk\$usernamesql" "SeLockMemoryPrivilege" -Confirm:$false
    Add-LoginToLocalPrivilege "Administrators" "SeDebugPrivilege" -Confirm:$false
    Add-LoginToLocalPrivilege "ipaniuk\$usernamesql" "SeManageVolumePrivilege" -Confirm:$false
    $accresult
    $accresult1
    }
#endregion Create-AD-User-Accounts

#region Modify-Unattended-Install-File
if (Get-ADDomain | Select -property DNSRoot | where {$_.DNSRoot -like "uk.experian.local"}) {
    write-host "Attempting to modify INI file with ExperianUK details"
    (get-content $installtemplate) | foreach-object {$_ -replace ';SQLSYSADMINACCOUNTS="EXPERIANUK', 'SQLSYSADMINACCOUNTS="EXPERIANUK' -replace "@domain@", "experianuk" -replace "@svcSQLAccount@", "$usernamesql" -replace "@svcAGTAccount@", "$usernameagt" -replace "@svcSQLpassword@", "$RndPwd1" -replace "@svcSQLAgentpassword@", "$RndPwd2" -replace "@sqlCollation@", "$sqlcollation"} | set-content $installtemplate
    }

    Elseif (Get-ADDomain | Select -property DNSRoot | where {$_.DNSRoot -like "gdc.local"}) {
    write-host "Attempting to modify INI file with GDC details"
    (get-content $installtemplate) | foreach-object {$_ -replace ';SQLSYSADMINACCOUNTS="GDC', 'SQLSYSADMINACCOUNTS="GDC' -replace "@domain@", "gdc" -replace "@svcSQLAccount@", "$usernamesql" -replace "@svcAGTAccount@", "$usernameagt" -replace "@svcSQLpassword@", "$RndPwd1" -replace "@svcSQLAgentpassword@", "$RndPwd2" -replace "@sqlCollation@", "$sqlcollation" -replace "ts command centre all users", "ADMIN EGOC Operations" -replace "ts-t-hs-serverops", "ADMIN DSG Engineers" } | set-content $installtemplate
    }
    Else {(Get-ADDomain | Select -property DNSRoot | where {$_.DNSRoot -like "ipani.uk.experian.com"})
    write-host "Attempting to modify INI file with IPANI details"
    (get-content $installtemplate) | foreach-object {$_ -replace ';SQLSYSADMINACCOUNTS="IPANIUK', 'SQLSYSADMINACCOUNTS="IPANIUK' -replace "@domain@", "ipaniuk" -replace "@svcSQLAccount@", "$usernamesql" -replace "@svcAGTAccount@", "$usernameagt" -replace "@svcSQLpassword@", "$RndPwd1" -replace "@svcSQLAgentpassword@", "$RndPwd2" -replace "@sqlCollation@", "$sqlcollation"} | set-content $installtemplate
    }

#endregion Modify-Unattended-Install-File

#### Start the Installation process
write-host "Attempting to start the SQL installation"
Start-Process -FilePath $cmdfile -WorkingDirectory $workingDir

exit 0
