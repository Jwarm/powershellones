 # Get the ID and security principal of the current user account
 $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
 $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
  
 # Get the security principal for the Administrator role
 $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
  
 # Check to see if we are currently running "as Administrator"
 if ($myWindowsPrincipal.IsInRole($adminRole))
    {
    # We are running "as Administrator" - so change the title and background color to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    clear-host
    }
 else
    {
    # We are not running "as Administrator" - so relaunch as administrator
    
    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    
    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";
    
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);
    
    # Exit from the current, unelevated, process
    exit
    }




Import-Module ActiveDirectory

Write-host "This PShell is used to automatically assigh uidnumber,gidnumber to newly-added account or account missing uid/gidnumber attribute!"



$ADuser = Read-Host -Prompt 'Input the new user samaccountname'

$ADuser1 = $ADuser

#$title    = 'Double Confirm'
#$question = 'Are you sure you want to proceed on assigning UID/GIDNumber for account you inputted?'
#$choices  = '&Yes', '&No'

#$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

#if ($decision -eq 0) {
 #   Write-Host 'confirmed, and go on assign IDs for ADuser'
#} else {
 #   Write-Host 'cancelled'
  #  exit 0
#}


$cmaxun = (Get-ADUser -Properties *  -Filter 'enabled -eq $true' | Measure-Object -property uidnumber -Maximum).Maximum


foreach ($user in $ADuser) {
   get-aduser -identity $user -properties * |select-object uidnumber,gidnumber,loginshell,unixhomedirectory| foreach{

   $uidnumber1=$_.uidnumber

   #write-host "Current UIDNUM: $uidnumber1"

   if([String]::IsNullOrEmpty($uidnumber1))##if string is null or empty
   {
   echo "Assigning required attributes for AD account:$user ..."
  $nunum = $cmaxun+1
  $ngum =  $nunum
  $lgshell = "/tin/tcsh"
   
   set-aduser -identity $user  -replace @{ uidNumber = "$nunum";  gidNumber = "$ngum"; loginshell = "$lgshell"; unixHomeDirectory = "/home/$user" }
    

  $p = $(get-aduser -identity $user -Properties * |select-object uidnumber,gidnumber,loginshell,unixhomedirectory)

  write-host "               "

  write-host "The attribtes for $user ....:"

  write-host $p
  write-host "               "
    
    } 

   else
   {write-host "The uidnumber for $user is already existing: $uidnumber1, no need to reassign, quitting... "}
   

 
   }
   }


 


Write-Host -NoNewLine "Press any key to end..."

#get-aduser $user -Properties * |select-object uidnumber,gidnumber,loginshell,unixhomedirectory
 
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")