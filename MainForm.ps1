<# 
.AUTHORS
    Pierre Emmanuel JOUBERT
    John PIGERET
.NAME
    EntityOnboarder GUI
.THANKS

#>
Function New-LogMessage(){
    Param ($Message = ".")
    $Message = "$(Get-Date -DisplayHint Time): $Message"
    Write-Verbose $Message
    Write-Output $Message | Out-File $global:gLogFile -Append -Force
 }
#Syntax examples for CMTRACE easy reading/colour coding of logs (Info, Warning, Error)
#New-LogMessage "INFO : standard log"
#New-LogMessage "WARNING : Warning received log"
#New-LogMessage "ERROR : Error returned #ERRORCODE"

############################################################################################
## Load Modules and authenticate ###
############################################################################################

#####
#Load Module Intune Mobilutils.UEM.IntuneBeta
#####
$ModuleIntuneBetaName = "Mobilutils.UEM.IntuneBeta"
$ModuleIntuneBetaFilename = "$ModuleIntuneBetaName.dll"
$ModuleIntuneBetaRelativePath = ".\Dependencies\$ModuleIntuneBetaFilename"
If (Test-Path $ModuleIntuneBetaRelativePath -PathType leaf ) {
	Write-Host "Module File : $ModuleIntuneBetaRelativePath Found." -ForegroundColor Green
	Import-Module $ModuleIntuneBetaRelativePath
} Else {
	Write-Host "Couldn't find module in $ModuleIntuneBetaRelativePath." -ForegroundColor Red
	Exit
}
$IsModuleLoaded = Get-Module -Name $ModuleIntuneBetaName
If ($null -eq $IsModuleLoaded) {
    Write-Host "Module not loaded..." -ForegroundColor Red
}
Write-Host "Module $ModuleIntuneBetaName is loaded." -ForegroundColor Green

#####
#Load Module Intune RedMobUtils.UEM.PSCommonFunctions
#####
$ModuleUEMName = "RedMobUtils.UEM.PSCommonFunctions"
$ModuleUEMFilename = "$ModuleUEMName.dll"
$ModuleUEMRelativePath = ".\Dependencies\$ModuleUEMFilename"
#Load Module UEM
If (Test-Path $ModuleUEMRelativePath -PathType leaf ) {
	Write-Host "Module File : $ModuleUEMRelativePath Found." -ForegroundColor Green
	Import-Module $ModuleUEMRelativePath
} Else {
	Write-Host "Couldn't find module in $ModuleUEMRelativePath." -ForegroundColor Red
	Exit
}
$IsModuleLoaded = Get-Module -Name $ModuleUEMName
If ($null -eq $IsModuleLoaded) {
    Write-Host "Module not loaded..." -ForegroundColor Red
}
Write-Host "Module $ModuleUEMName is loaded." -ForegroundColor Green


#####
#Load Module Intune AzureADPreview
#####
$ModuleAzureName = "AzureADPreview"
$IsModulePresent = Get-Module -ListAvailable | Where-Object {($_.Name).equals($ModuleAzureName)}
If ($null -eq $IsModulePresent) {
    Write-Host "Module not present..." -ForegroundColor Red
    Exit
}
Import-Module $ModuleAzureName
$IsModuleLoaded = Get-Module -Name $ModuleAzureName
If ($null -eq $IsModuleLoaded) {
    Write-Host "Module not Loaded..." -ForegroundColor Red
    Exit
}
Write-Host "Module $ModuleAzureName is loaded." -ForegroundColor Green


#####
#Load Module Intune ModuleMSGraphIntuneName
#####
$ModuleMSGraphIntuneName = "Microsoft.Graph.Intune"
$IsModulePresent = Get-Module -ListAvailable | Where-Object {($_.Name).equals($ModuleMSGraphIntuneName)}
If ($null -eq $IsModulePresent) {
    Write-Host "Module not present..." -ForegroundColor Red
    Exit
}
Import-Module $ModuleMSGraphIntuneName
$IsModuleLoaded = Get-Module -Name $ModuleMSGraphIntuneName
If ($null -eq $IsModuleLoaded) {
    Write-Host "Module not loaded..." -ForegroundColor Red
    Exit
}
Write-Host "Module $ModuleMSGraphIntuneName is loaded." -ForegroundColor Green
#we know out Module file exists


#create constants to know where credentials file shall be
$CredentialsFileFilename = 'Credentials.txt'
$CredentialFileRelativePath = $CredentialsFileFilename

#let see if our credential file exists
If (Test-Path $CredentialFileRelativePath -PathType leaf ) {
	Write-Host "File containing Credentials : $CredentialFileRelativePath Found." -ForegroundColor Green
} Else {
	Write-Host "Couldn't find file containing credentials : $CredentialFileRelativePath." -ForegroundColor Red
	Exit
}

#####
# Deals with credentials
#####
$fileCredentialsContent = Get-Content $CredentialFileRelativePath
$adminUsername = $fileCredentialsContent[0]
$adminPassword = $fileCredentialsContent[1] 
$adminSecurePassword = $adminPassword | ConvertTo-SecureString -AsPlainText -Force


$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($adminUsername, $adminSecurePassword)

Connect-MSGraph -PSCredential $creds
Connect-IntuneBeta -Username $adminUsername -Password $adminPassword -Domain 'tsodexo.com'
Connect-AzureAD -Credential $creds
Get-IntuneBetaAcquiredAuthToken

############################################################################################
## End Load Modules and Authenticate ###
############################################################################################


#region Timing In
$StartScript = Get-Date
#
#========== Création du LogFile sous le répertoire d'execution avec comme nom le nom du Script.ps1.Log=============###
#
$logPath = $Env:USERPROFILE
$global:gLogFile = "$logPath\OnBoarderGUI_$(get-date -Format dMHHMMss).log"
write-host $global:gLogFile
#New-LogMessage "=============== Début d'execution du script.....  ================================================================="
Write-UEMLogLine -Filename $global:gLogFile -Line "=============== Début d'execution du script.....  ================================================================="


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

<#region XMLFORM#>

$EntityOnboarder                 = New-Object system.Windows.Forms.Form
$EntityOnboarder.ClientSize      = '657,411'
$EntityOnboarder.text            = "EntityOnboarder"
$EntityOnboarder.TopMost         = $false

$TextBoxCountry                     = New-Object system.Windows.Forms.TextBox
$TextBoxCountry.text                = "FR"
$TextBoxCountry.width               = 170
$TextBoxCountry.height              = 30
$TextBoxCountry.Font               = 'Microsoft Sans Serif,10'
$TextBoxCountry.location            = New-Object System.Drawing.Point(28,77)

$TextBoxEntity                      = New-Object system.Windows.Forms.TextBox
$TextBoxEntity.text                 = "OSS"
$TextBoxEntity.width                = 136
$TextBoxEntity.height               = 30
$TextBoxEntity.Font               = 'Microsoft Sans Serif,10'
$TextBoxEntity.location             = New-Object System.Drawing.Point(236,77)


$Validate                        = New-Object system.Windows.Forms.Button
#$Validate.BackColor              = "#7ed321"
$Validate.text                   = "Validate"
$Validate.width                  = 100
$Validate.height                 = 30
$Validate.location               = New-Object System.Drawing.Point(440,79)
$Validate.Font                   = 'Microsoft Sans Serif,10'

$Instructions                    = New-Object system.Windows.Forms.Label
$Instructions.text               = "Please type in your Country and Entity codes and Validate to proceed..."
$Instructions.AutoSize           = $true
$Instructions.width              = 25
$Instructions.height             = 10
$Instructions.location           = New-Object System.Drawing.Point(28,22)
$Instructions.Font               = 'Microsoft Sans Serif,10'

$Groups                          = New-Object system.Windows.Forms.Button
$Groups.BackColor                = "#4a90e2"
$Groups.text                     = "Groups"
$Groups.width                    = 80
$Groups.height                   = 30
$Groups.location                 = New-Object System.Drawing.Point(28,135)
$Groups.Font                     = 'Microsoft Sans Serif,10'
$Groups.Visible                  = $false

$Tags                            = New-Object system.Windows.Forms.Button
$Tags.BackColor                  = "#4a90e2"
$Tags.text                       = "Tags"
$Tags.width                      = 80
$Tags.height                     = 30
$Tags.location                   = New-Object System.Drawing.Point(28,189)
$Tags.Font                       = 'Microsoft Sans Serif,10'
$Tags.Visible                     = $false


$Devices                         = New-Object system.Windows.Forms.Button
#$Devices.BackColor               = "#4a90e2"
$Devices.text                    = "Devices"
$Devices.width                   = 80
$Devices.height                  = 30
$Devices.location                = New-Object System.Drawing.Point(28,237)
$Devices.Font                    = 'Microsoft Sans Serif,10'
$Devices.Visible                 = $false

$Roles                           = New-Object system.Windows.Forms.Button
$Roles.BackColor                 = "#4a90e2"
$Roles.text                      = "Roles"
$Roles.width                     = 80
$Roles.height                    = 30
$Roles.location                  = New-Object System.Drawing.Point(28,288)
$Roles.Font                      = 'Microsoft Sans Serif,10'
$Roles.Visible                   = $false

$LogsTest                        = New-Object system.Windows.Forms.Label
$LogsTest.text                   = "Intune Tool Box Beta Version"
$LogsTest.AutoSize               = $true
$LogsTest.width                  = 25
$LogsTest.height                 = 10
$LogsTest.location               = New-Object System.Drawing.Point(28,372)
$LogsTest.Font                   = 'Microsoft Sans Serif,10'

$DoItAll                         = New-Object system.Windows.Forms.Button
$DoItAll.BackColor               = "#4a7de2"
$DoItAll.text                    = "Do It All!"
$DoItAll.width                   = 146
$DoItAll.height                  = 74
$DoItAll.location                = New-Object System.Drawing.Point(440,165)
$DoItAll.Font                    = 'Microsoft Sans Serif,10,style=Bold'
$DoItAll.Visible                 = $false

$Label_Groups                    = New-Object system.Windows.Forms.Label
$Label_Groups.text               = "Create Groups for Entity"
$Label_Groups.AutoSize           = $true
$Label_Groups.width              = 25
$Label_Groups.height             = 10
$Label_Groups.location           = New-Object System.Drawing.Point(109,145)
$Label_Groups.Font               = 'Microsoft Sans Serif,10'
$Label_Groups.Visible            = $false

$Label_Tags                      = New-Object system.Windows.Forms.Label
$Label_Tags.text                 = "Create and assign Tags"
$Label_Tags.AutoSize             = $true
$Label_Tags.width                = 25
$Label_Tags.height               = 10
$Label_Tags.location             = New-Object System.Drawing.Point(109,196)
$Label_Tags.Font                 = 'Microsoft Sans Serif,10'
$Label_Tags.Visible              = $false

$Label_Devices                   = New-Object system.Windows.Forms.Label
$Label_Devices.text              = "Place all devices in Entity groups"
$Label_Devices.AutoSize          = $true
$Label_Devices.width             = 25
$Label_Devices.height            = 10
$Label_Devices.location          = New-Object System.Drawing.Point(109,248)
$Label_Devices.Font              = 'Microsoft Sans Serif,10'
$Label_Devices.Visible           = $false

$Label_Roles                     = New-Object system.Windows.Forms.Label
$Label_Roles.text                = "Assign Intune Roles"
$Label_Roles.AutoSize            = $true
$Label_Roles.width               = 25
$Label_Roles.height              = 10
$Label_Roles.location            = New-Object System.Drawing.Point(109,297)
$Label_Roles.Font                = 'Microsoft Sans Serif,10'
$Label_Roles.Visible             = $false

$Cancel                          = New-Object system.Windows.Forms.Button
$Cancel.BackColor                = "#d0021b"
$Cancel.text                     = "Cancel - Click Twice!"
$Cancel.width                    = 150
$Cancel.height                   = 30
$Cancel.location                 = New-Object System.Drawing.Point(440,288)
$Cancel.Font                     = 'Microsoft Sans Serif,10,style=Bold'
$Cancel.ForeColor                = "#f7eded"


$LogViewer                       = New-Object system.Windows.Forms.Button
$LogViewer.text                  = "LogViewer"
$LogViewer.width                 = 132
$LogViewer.height                = 30
$LogViewer.location              = New-Object System.Drawing.Point(440,360)
$LogViewer.Font                  = 'Microsoft Sans Serif,10'

<# Endregion XMLFORM #>

#Variables to get from form
$EntityOnboarder.controls.AddRange(@($TextBoxCountry,$TextBoxEntity,$Validate,$Instructions,$Groups,$Tags,$Devices,$Roles,$LogsTest,$DoItAll,$Label_Groups,$Label_Tags,$Label_Devices,$Label_Roles,$Cancel,$LogViewer))
$ValidationOK = $false

#Global Variables common to whole script not from Form
$global:gEntity = $null                 #from validate function
$global:gCountry = $null                #from validate function
$global:gEntityScopeTag = $null         #from validate function
$global:gUEMUsers = $null               #from createGroup function
$global:gUEMKeyUsers = $null            #from createGroup function
$global:gUEMAndroid = $null             #from createGroup function
$global:gUEMDevices = $null             #from createGroup function
$global:gUEMIOS = $null                 #from createGroup function
$global:gUEMW10 = $null                 #from createGroup function
$global:gGLBUEMDevices= $null           #from createGroup function
$global:gGLBUEMAndroid = $null          #from createGroup function
$global:gGLBUEMIOS = $null              #from createGroup function
$global:gGLBUEMW10 = $null              #from createGroup function
$global:gGLBUEMUsers = $null            #from createGroup function
$global:gListGroupNames = $null
$global:gListGroupIds = $null

write-host "Valdation passed: $ValidationOK"
Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : Valdation passed: $ValidationOK"

#Write your logic code here
$Validate.Add_Click({ Validate_Function })
$LogViewer.Add_Click({ Lauch_Viewer_Function })
$DoItAll.Add_Click({ Onboard_Complete_Function })
$Roles.Add_Click({ Assign_Roles_Function })
$Tags.Add_Click({ Add_Tags_Function })
$Devices.Add_Click({ Devices_To_Groups_Function })
$Groups.Add_Click({ Create_Groups_Function })
$Cancel.Add_Click({ Exit_Cancel})



Function Validate_Function
{
    #TODO: check Synched USER GROUPS and Licencing Option
    $CountryValidated = $false
    $Country_Selected = $TextBoxCountry.text
    $szPattern = '/^A[^ABCHJKNPVY]|B[^CKPUX]|C[^BEJPQST]|D[EJKMOZ]|E[CEGHRST]|F[IJKMOR]|G[^CJKOVXZ]|H[KMNRTU]|I[DEL-OQ-T]|J[EMOP]|K[EGHIMNPRWYZ]|L[ABCIKR-VY]|M[^BIJ]|N[ACEFGILOPRUZ]|OM|P[AE-HK-NRSTWY]|QA|R[EOSUW]|S[^FPQUW]|T[^ABEIPQSUXY]|U[AGMSYZ]|V[ACEGINU]|WF|WS|YE|YT|Z[AMW]$/i'
    
    Write-host "User clicked on Validate"
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : User clicked on Validate"

    If ($Country_Selected -match $szPattern -and $Country_Selected.Length -eq 2) {
        $CountryValidated = $true
        $global:gCountry = $Country_Selected.ToUpper()
        write-host "User selected country: $Country_Selected" -ForegroundColor Green
        Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : User selected country: $Country_Selected"
        Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : Country Validation passed: $CountryValidated"
    } Else {
        write-host "User selected country: $Country_Selected" -ForegroundColor Red
        Write-UEMLogLine -Filename $global:gLogFile -Line "WARNING : User selected country: $($Country_Selected)"
        Write-UEMLogLine -Filename $global:gLogFile -Line "WARNING : Country Validation passed: $CountryValidated"
    }

    $EntityValidated= $false
    $Entity_Selected = $TextBoxEntity.text
    #make it UpperCase
    $Entity_Selected = $Entity_Selected.ToUpper()

    If ($Entity_Selected -match "(OSS|BRS|PHS|GCP)") {
        $EntityValidated= $true
        If ( ($Entity_Selected -eq 'GCP') -And ($Country_Selected -ne 'FR') ) {
            Write-host "User selected Entity: $($Entity_Selected) which means Global CorPorate, so it is reserved for country FR."
            Write-UEMLogLine -Filename $global:gLogFile -Line "WARNING : Country Validation passed: $EntityValidated" 
            $EntityValidated = $false
        } 
        Else 
        {
            $global:gEntity = $Entity_Selected.ToUpper()
            Write-host "User selected Entity: $($Entity_Selected)" -ForegroundColor Green
            Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : User selected Entity: $($Entity_Selected)"
            Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : Entity Validation : $EntityValidated"
        }
    }
    Else
    {
        Write-host "User selected Entity: $($Entity_Selected)" -ForegroundColor Red
        Write-UEMLogLine -Filename $global:gLogFile -Line "WARNING: User selected Entity: $($Entity_Selected)" 
        Write-UEMLogLine -Filename $global:gLogFile -Line "WARNING : Country Validation passed: $EntityValidated"   
    }


    if( ($EntityValidated -eq $true) -and ($CountryValidated -eq $true))
    {
        $ValidationOK = $true
        #$global:gEntityScopeTag = $global:gCountry + " - " + $global:gEntity + " - ScopeTag"
        $global:gEntityScopeTag = Get-UEMRoleScopeTagName -Country $global:gCountry -Entity $global:gEntity
        Write-host "User selected : $($Country_Selected) and $($Entity_Selected) " -ForegroundColor Green
        Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : User selected : $($Country_Selected) and $($Entity_Selected) "
        write-host "Valdation passed: $ValidationOK" -ForegroundColor Green
        Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : Valdation passed: $ValidationOK"
        Write-host "Entity Scope Tag initiated with value : $global:gEntityScopeTag " -ForegroundColor Green
        Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : Entity Scope Tag initiated with value : $global:gEntityScopeTag"

        #Here you show your buttons
        $Validate.BackColor              = "#7ed321"
        $Label_Roles.Visible             = $true
        $Label_Devices.Visible           = $true
        $Label_Tags.Visible              = $true
        $Label_Groups.Visible            = $true
        $DoItAll.Visible                 = $true
        $Roles.Visible                   = $true
        $Devices.Visible                 = $true
        $Tags.Visible                    = $true
        $Groups.Visible                  = $true
        $EntityOnboarder.Refresh()

    }
    If ($true -eq $EntityValidated) {
        $global:gListGroupNames = Get-UEMGroupNames -Country $global:gCountry -Entity $global:gEntity
    }
}


Function Lauch_Viewer_Function 
{
    Start-Process -FilePath C:\windows\CMTrace.exe $global:gLogFile
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : User selected to launch CMTRACE"
}


Function Assign_Roles_Function
{
    Write-Host "Assigning role to entity admins and others"
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : NOT IMPLEMENTED YET : User selected to launch Assign Roles"
    # needs variables: AdminRoleId, ReportRoleId, SupportRoleId, Entity Groups Ids, Entity ScopeTagId
    #get intune role definitions (Global Ones...)
    #We need to seek if role assignement exists already
    #also gather rolescopetag id 
    $szRoleDefinitionName = Get-UEMRoleDefinitionName -ForWhom 'EntityAdmins'
    $oRoleDefinitionGLBEntityAdmins = Get-IntuneRoleDefinition | Where-Object {($_.displayName).equals($szRoleDefinitionName)}
    
    Write-Host "Now we will see if role already exists..."
    If ($null -eq $oRoleDefinitionGLBEntityAdmins ) {
        $szLine = "Impossible to find the Role Definition named : 'GLB - Role - EntityAdmins'"
        Write-Host $szLine
        Write-UEMLogLine -Filename $global:gLogFile -Line "ERROR : $szLine"
        Return
    }
    Write-Host "Now we will see if role assignment already exists..."
    $szRoleAssignmentName = Get-UEMRoleAssignmentName -Country $global:gCountry -Entity $global:gEntity -ForWhom 'EntityAdmins'
    $oRoleAssignmentEntityAdmins = Get-IntuneRoleAssignment | Where-Object {($_.displayName).equals($szRoleAssignmentName)}
    If ($null -ne $oRoleAssignmentEntityAdmins ) {
        $szLine = "The Role Assignment you want to create already exists... abording."
        Write-Host $szLine
        Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : $szLine"
        Return
    }
    if ($null -eq $global:gListGroupIds) {
        $global:gListGroupIds = GetGroupAADIdsList
    }
    #lol
    #Write-Host 'EntityAdmins '$global:gListGroupIds[$global:gListGroupNames['EntityAdmins']]
    #Write-Host 'Users '$global:gListGroupIds[$global:gListGroupNames['Users']]
    #Write-Host 'Devices '$global:gListGroupIds[$global:gListGroupNames['Devices']]
    #From now on we know roleDefinition exists and RoleAssignment doesn't for this
    $szLine = 'Will Create the new RoleAssignemt ' + $szRoleAssignmentName
    Write-Host $szLine
    Write-UEMLogLine -Filename $global:gLogFile -Line $szLine
    New-IntuneBetaRoleAssignment -RoleDefinitionId $oRoleDefinitionGLBEntityAdmins.id `
    -DisplayName $szRoleAssignmentName -Description $szRoleAssignmentName `
    -AdminGroupsIds @($global:gListGroupIds[$global:gListGroupNames['EntityAdmins']]) `
    -ScopeMembersGroupsIds @($global:gListGroupIds[$global:gListGroupNames['Users']], $global:gListGroupIds[$global:gListGroupNames['Devices']])  

    #get id of the created roleassignment
    $oRoleAssignmentEntityAdmins = Get-IntuneRoleAssignment | Where-Object {($_.displayName).equals($szRoleAssignmentName)}
    If ($null -eq $oRoleAssignmentEntityAdmins) {
        $szLine = 'RoleAssignment creation Error.'
        Write-Host $szLine
        Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : $szLine"
        Return
    }
    $szLine = 'RoleAssignment with name : '+$szRoleAssignmentName+' created.'
    Write-Host $szLine
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : $szLine"

    $oListRoleScopeTags = Get-IntuneBetaRoleScopeTags
    $nRoleScopeTagId = 0
    $szRoleScopeTagName = Get-UEMRoleScopeTagName -Country $global:gCountry -Entity $global:gEntity
    Foreach ($oneObj in $oListRoleScopeTags) {
        If ($oneObj.displayName -eq $szRoleScopeTagName ) {
            $nRoleScopeTagId = $oneObj.id
            Break
        }
    }
    If ($nRoleScopeTagId -eq 0) {
        $szLine = 'Role Scope Tag with name '+$szRoleScopeTagName + ' not found, abording.'
        Write-Host $szLine
        Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : $szLine"
        Return
    }
    #now we want to put the scopeTag
    $szLine = 'Will exexute AddIntuneBetaRoleAssignmentRoleScopeTag -Id '+$oRoleAssignmentEntityAdmins.id+' -RoleScopeTagId '+$nRoleScopeTagId
    Write-Host $szLine
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : $szLine"

    Add-IntuneBetaRoleAssignmentRoleScopeTag -Id $oRoleAssignmentEntityAdmins.id -RoleScopeTagId $nRoleScopeTagId

    $oRoleAssignmentRoleScopeTag = Get-IntuneBetaRoleAssignmentRoleScopeTags -Id $oRoleAssignmentEntityAdmins.id
    If ($null -eq $oRoleAssignmentRoleScopeTag) {
        $szLine = 'Error when assigning Scope ' + $szRoleScopeTagName + '' + $szRoleAssignmentName
        Write-Host $szLine
        Write-UEMLogLine -Filename $global:gLogFile -Line "ERROR : $szLine"
        Return
    
    }

    $szLine = 'Scope tag '+$szRoleScopeTagName+' with Id: '+$oRoleAssignmentRoleScopeTag.id+' has been assgined to : '+$oRoleAssignmentEntityAdmins.displayName
    Write-Host $szLine
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : $szLine"
    
    Return
}


Function New-IntuneBetaScopeTag () 
{
      [cmdletbinding()]

      param
      (
          $ScopeTagName
      )
      
      $graphApiVersion = "beta"
      $Resource = "deviceManagement/roleScopeTags"
          Write-host $ScopeTagName
      $JSON = @"

      {
      "@odata.type": "#microsoft.graph.roleScopeTag",
      "displayName": "$ScopeTagName",
      "description": "$ScopeTagName",
      "isBuiltIn": true
      }

"@
          $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"
          Invoke-MSGraphRequest -Url $uri -httpMethod Post -Content $JSON

    
}

Function Add_Tags_Function
{
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : User selected to launch Add Tags"
    Write-host "Entity Scope Tag is : $global:gEntityScopeTag" -ForegroundColor Green
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO: Entity Scope Tag is : $global:gEntityScopeTag"

    try {
        #New-IntuneBetaScopeTag -ScopeTagName $global:gEntityScopeTag
        $oResNewRoleScopeTag = New-IntuneBetaRoleScopeTag -Name $global:gEntityScopeTag
        If ($oResNewRoleScopeTag.GetType().fullname -eq 'System.String')
        {
            $oResNewRoleScopeTag
            Write-host "Error: Error creating ScopeTag $global:gEntityScopeTag " -foregroundcolor Red
            Write-UEMLogLine -Filename $global:gLogFile -Line "Error: Error creating ScopeTag $global:gEntityScopeTag"
        }
        Else
        {
            $Line ="Entity Scope Tag Created : $global:gEntityScopeTag with id: "+$oResNewRoleScopeTag.id
            Write-host $Line -ForegroundColor Green
            Write-UEMLogLine -Filename $global:gLogFile -Line "INFO: $Line"
            
            Write-Host "Will invoke GetGroupAADIdsList"
            
            if ($null -eq $global:gListGroupIds) {
                $global:gListGroupIds = GetGroupAADIdsList
            }
            Write-Host "done invoking GetGroupAADIdsList"
            $global:gListGroupIds.keys | ForEach-Object{
                $message = '{0} is {1} has id!' -f $_, $global:gListGroupIds[$_]
                Write-Host $message
            }

            Write-Host "Will Invoke New-IntuneBetaRoleScopeTagGroupAssignment -Id "$oResNewRoleScopeTag.id" -GroupId "$global:gListGroupIds[$global:gListGroupNames['Devices']]
            $oResAssign = New-IntuneBetaRoleScopeTagGroupAssignment -Id $oResNewRoleScopeTag.id -GroupId $global:gListGroupIds[ $global:gListGroupNames['Devices'] ]
            If ($oResAssign.GetType().fullname -eq 'System.String') {
                $oResAssign
                $szLogLine = "Error assigning group " + $global:gListGroupNames['Devices'] + "to RoleScopeTag $global:gEntityScopeTag "
                Write-host $szLogLine -foregroundcolor Red
                Write-UEMLogLine -Filename $global:gLogFile -Line "Error: $szLogLine"
            }
            Else {
                $szLogLine = "Group " + $global:gListGroupNames['Devices'] + " assigned to RoleScopeTag $global:gEntityScopeTag "
                Write-host $szLogLine -foregroundcolor Green
                Write-UEMLogLine -Filename $global:gLogFile -Line "INFO: $szLogLine"
            }
        }
    }
    Catch {
        Write-host "EError: Error creating ScopeTag $global:gEntityScopeTag " -foregroundcolor Red
        Write-UEMLogLine -Filename $global:gLogFile -Line "EError: Error creating ScopeTag $global:gEntityScopeTag"
    }
}
    
    



Function Create_Groups_Function
{
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : User selected to launch Create Groups"
    $Country_Selected = $TextBoxCountry.text
    $Country = $Country_Selected.ToUpper()

    $Entity_Selected = $TextBoxEntity.text
    $Entity = $Entity_Selected.ToUpper()

    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : Country = $Country and Entity = $Entity"
    # Create Devices Groups Names
    $UEMEntityAdmins = "SG.AZ." + $Country + "." + $Entity + "-UEM-EntityAdmins"
    $UEMSupport = "SG.AZ." + $Country + "." + $Entity + "-UEM-Support"
    $UEMReporting = "SG.AZ." + $Country + "." + $Entity + "-UEM-Reporting"
        $UEMUsers = "SG.AZ." + $Country + "." + $Entity + "-UEM-Users"
        $UEMKeyUsers = "SG.AZ." + $Country + "." + $Entity + "-UEM-Key-Users"
        $UEMAndroid = "SG.AZ." + $Country + "." + $Entity + "-UEM-Android"
        $UEMDevices = "SG.AZ." + $Country + "." + $Entity + "-UEM-Devices" 
        $UEMIOS = "SG.AZ." + $Country + "." + $Entity + "-UEM-iOS"
        $UEMW10 = "SG.AZ." + $Country + "." + $Entity + "-UEM-W10"
        $GLBUEMDevices= "SG.AZ.GLB-UEM-Devices"
        $GLBUEMAndroid = "SG.AZ.GLB-UEM-Android"
        $GLBUEMIOS = "SG.AZ.GLB-UEM-IOS"
        $GLBUEMW10 = "SG.AZ.GLB-UEM-W10"
        $GLBUEMUsers = "SG.AZ.GLB-UEM-Users"
        $GLBUEMEntityAdmins = "SG.AZ.GLB-UEM-EntityAdmins"
        $GLBUEMSupport = "SG.AZ.GLB-UEM-Support"
        $GLBUEMReporting = "SG.AZ.GLB-UEM-Reporting"

        $global:gUEMUsers = $UEMUsers               
        $global:gUEMKeyUsers = $UEMKeyUsers            
        $global:gUEMAndroid = $UEMAndroid             
        $global:gUEMDevices = $UEMDevices             
        $global:gUEMIOS = $UEMW10                 
        $global:gUEMW10 = $UEMW10                 
        $global:gGLBUEMDevices= $GLBUEMDevices           
        $global:gGLBUEMAndroid = $GLBUEMAndroid          
        $global:gGLBUEMIOS = $GLBUEMIOS              
        $global:gGLBUEMW10 = $GLBUEMW10              
        $global:gGLBUEMUsers = $GLBUEMUsers 
         
    #Create AzureAD Groups if they do not exist
    $GroupsToCreate = $UEMUsers,$UEMAdmins,$UEMAndroid,$UEMDevices,$UEMIOS,$UEMW10,$UEMReporting,$UEMSupport,$UEMKeyUsers,$GLBUEMW10,$GLBUEMAndroid,$GLBUEMIOS,$GLBUEMDevices,$GLBUEMUsers,$UEMEntityAdmins,$UEMSupport,$UEMReporting

        foreach($GroupName in $GroupsToCreate){
                    $GroupExists = Get-AzureADGroup -SearchString $GroupName
                    if ($NULL -ne $GroupExists) 
                            {Write-Host "Warning: Group $($GroupName) already exists." -foregroundcolor Yellow
                            Write-UEMLogLine -Filename $global:gLogFile -Line "Warning: Group $($GroupName) already exists."}
                    else {
                            #Create Group
                            try {
                                New-AzureADGroup -DisplayName $GroupName -MailEnabled $false -MailNickName $GroupName -SecurityEnabled $true
                                Write-host "Info: Group $($GroupName) created." -foregroundcolor Green
                                Write-UEMLogLine -Filename $global:gLogFile -Line "Info: Group $($GroupName) created."}
                            Catch {
                                Write-host "Error: Error creating Group $($GroupName) " -foregroundcolor Red
                                Write-UEMLogLine -Filename $global:gLogFile -Line "Error: Error creating Group $($GroupName)"}
                            #Add Owners        
                            try {
                                Add-AzureADGroupOwner -ObjectId (Get-AzureADGroup -SearchString $GroupName).ObjectID -RefObjectId (Get-AzureADUser -SearchString '_pjoubert.AZ').ObjectID
                                Write-host "Info: _pjoubert.AZ added as owner of Group $($GroupName)." -foregroundcolor Green
                                Write-UEMLogLine -Filename $global:gLogFile -Line "Info: _pjoubert.AZ added as owner of Group $($GroupName)."
                                Add-AzureADGroupOwner -ObjectId (Get-AzureADGroup -SearchString $GroupName).ObjectID -RefObjectId (Get-AzureADUser -SearchString '_jpigeret.AZ').ObjectID
                                Write-host "Info: _jpigeret.AZ added as owner of Group $($GroupName)." -foregroundcolor Green
                                Write-UEMLogLine -Filename $global:gLogFile -Line "Info: _jpigeret.AZ added as owner of Group $($GroupName)."}
                            catch {
                                Write-host "Error: PJO/JPI NOT added as owners of Group $($GroupName)." -foregroundcolor Red
                                Write-UEMLogLine -Filename $global:gLogFile -Line "Error: PJO/JPI NOT added as owners of Group $($GroupName)."}
                        }
                }




    function Add-NestedGroup {
        param( [string]$Parent, [string]$Child )
        try {   
                Add-AzureADGroupMember -ObjectId $((Get-AzureADGroup -SearchString $Parent).ObjectID) -RefObjectId $((Get-AzureADGroup -SearchString $Child).ObjectID) 
                Write-host "Info: Group $($Child) was Added to $($Parent) Group." -foregroundcolor Green
                Write-UEMLogLine -Filename $global:gLogFile -Line "Info: Group $($Child) was Added to $($Parent) Group."}
            Catch {
                Write-host "Error: Group $($Child) NOT Added to $($Parent) Group." -foregroundcolor Red
                Write-UEMLogLine -Filename $global:gLogFile -Line "Error: Group $($Child) NOT Added to $($Parent) Group."}
    }

    #Nests IOS,Android and W10 groups into Devices parent group
    #Nest each local group in Global group
        Add-NestedGroup -Parent $UEMDevices -Child $UEMAndroid
        Add-NestedGroup -Parent $UEMDevices -Child $UEMIOS
        Add-NestedGroup -Parent $UEMDevices -Child $UEMW10
        Add-NestedGroup -Parent $GLBUEMDevices -Child $UEMDevices
        Add-NestedGroup -Parent $GLBUEMAndroid -Child $UEMAndroid
        Add-NestedGroup -Parent $GLBUEMIOS -Child $UEMIOS
        Add-NestedGroup -Parent $GLBUEMW10 -Child $UEMW10
    #Nests KeyUsers to Users Parent group
        Add-NestedGroup -Parent $UEMUsers -Child $UEMKeyUsers
        Add-NestedGroup -Parent $GLBUEMUsers -Child $UEMUsers
        Add-NestedGroup -Parent $GLBUEMEntityAdmins -Child $UEMEntityAdmins
        Add-NestedGroup -Parent $GLBUEMSupport -Child $UEMSupport
        Add-NestedGroup -Parent $GLBUEMReporting -Child $UEMReporting

        $global:gListGroupIds = GetGroupAADIdsList
}

Function GetGroupAADIdsList
{
    #$lGroupNames = Get-UEMGroupNames -Country $global:gCountry -Entity $global:gEntity
    $hGroupIds = @{}
    Foreach ($oneGroupName in $global:gListGroupNames.Values)
    {
        $GroupObject = Get-AzureADGroup -SearchString $oneGroupName
        $hGroupIds.add($oneGroupName, $GroupObject.ObjectId)
    }
    
    return ( $hGroupIds )
}

Function Devices_To_Groups_Function
{
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : NOT IMPLEMENTED YET : User selected to launch Devices to Groups"
    #list Users from Entity-UEM-Users
    #for each user in group, find devices enrolled and assign tag
}

Function Onboard_Complete_Function 
{
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : User selected to launch Total Onboarding"
    
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : Creating Groups..."
    Create_Groups_Function
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : Done Creating Groups!"

    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : Creating Scope Tag..."
    Add_Tags_Function
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO :Done  Creating Scope Tag!"
}



#Cancel Button closes form cleanly
Function Exit_Cancel
{
    Write-UEMLogLine -Filename $global:gLogFile -Line "INFO : User selected to Exit/Cancel"
    $Cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $EntityOnboarder.CancelButton = $cancel
    $EntityOnboarder.Controls.Add($cancel)
}


[void]$EntityOnboarder.ShowDialog()


#region Timing Out
#Fonction de calcul du temps d'execution du script
#
$StopScript = Get-Date
$timespan = new-timespan -seconds $(($StopScript-$startScript).totalseconds) 
$ScriptTime = '{0:00}h:{1:00}m:{2:00}s' -f $timespan.Hours,$timespan.Minutes,$timespan.Seconds
#
Write-UEMLogLine -Filename $global:gLogFile -Line "============ Fin d'execution du script..... en $ScriptTime ========================================================"
#endregion Timing Out
#=================================================########### 
