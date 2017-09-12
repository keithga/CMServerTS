<#

Verify that the correct components are installed on the master CM deployment server.
This is the server that will create the 

#>

[cmdletbinding()]
param()

Write-Verbose "Verify MDT is installed"

Write-Verbose "Verify ADK is installed"

Write-Verbose "copy MDT package stuff to MDT Package"
Write-Verbose "TODO: CmTrace and prereqs"

Write-Verbose @"

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
