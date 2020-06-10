<#
# authenticate to MSGraph (leveraging 2 modules)
#>
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

