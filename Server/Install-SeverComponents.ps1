<#

Verify that the correct components are installed on the master CM deployment server.
This is the server that will create the 

#>

[cmdletbinding()]
param(
    [version] $RequiredMDT = '6.3.8443.1000',
    [version] $RequiredADK = '10.0.15063.0',
    [parameter(Mandatory=$true)]
    [string] $MDTScripts,
    [parameter(Mandatory=$true)]
    [string] $MDTSettings,
    [switch] $FInal

)

$ErrorActionPreference = 'stop'

#region Verify MDT

Write-Verbose "Verify MDT is installed"

$CurrentMDT = get-itemproperty 'HKLM:\Software\microsoft\Deployment 4\' | 
    ForEach-Object Install_Dir |
    ForEach-Object { join-path $_ 'bin\Microsoft.BDD.CM12Actions.dll' } | 
    foreach-object { [System.Diagnostics.FileVersionInfo]::GetVersionInfo( $_ ) } | 
    ForEach-Object FileVersion

if ( $CurrentMDT -lt $RequiredMDT ) {
    throw "Current MDT Version $CurrentMDT is less than required version $RequiredMDT"
}

write-verbose "Current MDT Version $CurrentMDT required version $RequiredMDT"

#endregion

#region Verify ADK

Write-Verbose "Verify ADK is installed"

$CurrentADK = Get-ItemProperty 'HKLM:\Software\WOW6432Node\microsoft\Windows Kits\Installed Roots' | 
    ForEach-Object KitsRoot10 | 
    ForEach-Object { join-path $_ 'Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\en-us\winpe.wim' } | 
    ForEach-Object { Get-WindowsImage -ImagePath $_ -Index 1 } |
    ForEach-Object { $_.Version -as [version] }

if ( $CurrentADK -lt $RequiredADK ) {
    throw "Current ADK Version $CurrentADK is less than required version $RequiredADK"
}

write-verbose "Current ADK Version $CurrentADK required version $RequiredADK"

#endregion

#region Copy components...

if ( $MDTScripts ) {

    Write-Verbose "copy $PSScriptRoot\..\MDTPackage $MDTScripts"
    robocopy /e /ndl /np "$PSScriptRoot\..\MDTPackage" "$MDTScripts" | Out-String -Width 200 | write-verbose

    'c:\storage\cmtrace.exe','d:\storage\cmtrace.exe','c:\windows\system32\cmtrace.exe' | 
        Where-Object { Test-Path $_ } |
        ForEach-Object { 
            Write-Verbose "copy $_ $MDTScripts\`$OEM`$\`$1\Storage\"
            robocopy /ndl /np "$_\.." "$MDTScripts\`$OEM`$\`$1\Storage\" 'cmtrace.exe' | Out-String -Width 200 | write-verbose
        }

}

if ( $MDTSettings ) {

    Write-Verbose "copy $PSScriptRoot\..\SettingsPackage $MDTSettings"
    robocopy /e /ndl /np "$PSScriptRoot\..\SettingsPackage" "$MDTSettings" | Out-String -Width 200 | write-verbose

}

#endregion

Write-Verbose @"

###########################################################
###########################################################
###########################################################


Task Sequence Changes:

Custom Application Steps:
* Custom - Initialize Secondary Volumes - Initialize-SecondaryPartitions.ps1
* Custom - Copy $OEM$ Folder - cscript.exe "%deployroot%\scripts\Extras\ZTICopyOEM.wsf"
* Uninstall Roles
* Install Roles
* Install Software
* Convert list to two digits
* Install Applications
* Custom - Initialize Server Common - %DeployRoot%\Scripts\Extras\Initialize-ServerCommon.ps1 -LocalAdminGroupAdd FooBar


Server modification TBD:

; MDT
% Package %

; SQL Server 2014,
%deployroot%\Applications\INSTALL - SQL 2014\INSTALL_SQL.ps1

; ConfigMGr2012

"@
