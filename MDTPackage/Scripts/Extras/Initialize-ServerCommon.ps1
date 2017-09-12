#Requires -RunAsAdministrator
#requires -Version 5.0

<#


#>

[cmdletbinding()]
param(
    [string[]] $LocalAdminGroupAdd,
    [string[]] $LocalAdminGroupDel,

    [switch] $Final
    )

$ErrorActionPreference = 'stop'

<##############################################################################
#
#  Application custom actions...
#
###############################################################################>

#region Common Look and Feel
#######################################

Write-Host "Disable Server Manager at Startup"
reg.exe add HKLM\Software\Policies\Microsoft\Windows\Server\ServerManager /v DoNotOpenAtLogon /t REG_DWORD /d 1

Write-Host 'Disable IEEsc'

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -Name 'IsInstalled' -Value 0
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' -Name 'IsInstalled' -Value 0


#endregion

#region Remote Access..
#######################################

Write-Host "Enable Remote Desktop"
reg.exe add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0x00000000 /f
# netsh.exe advfirewall firewall set rule group="remote desktop" new enable=Yes

write-host "Ensure that WinRM is enabled"
& WinRM quickconfig -quiet -force
Enable-PSRemoting -force -ErrorAction SilentlyContinue

Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" –Enabled True

#endregion

#region LocalGroup
#######################################

Write-Host "LocalGroup modifications"

$LocalAdminGroupAdd | ForEach-Object { 
    Write-Host "Add $_ to Local Administrators Group"
    net.exe localgroup administrators /add "$_"
}

$LocalAdminGroupDel | ForEach-Object { 
    Write-Host "Remove  $_ from Local Administrators Group"
    net.exe localgroup administrators /delete "$_"
}

#endregion

<##############################################################################
#
#  Application custom actions...
#
###############################################################################>

#region Configure WSUS if installed previously.
#######################################

Write-Host "Test for WSUS"
Import-Module ServerManager -ErrorAction SilentlyContinue
if ( -not ( get-windowsfeature -Name UpdateServices,NET-WCF-HTTP-Activation45 | Where-Object InstallState -eq Available ) )
{
    Write-Host "Quick Configure  WSUS"

    & "C:\Program Files\Update Services\Tools\WsusUtil.exe" POSTINSTALL CONTENT_DIR=c:\WSUS
    & "C:\Program Files\Update Services\Tools\WsusUtil.exe" POSTINSTALL /servicing

}

#endregion

#region Configure WDS if installed previously.
#######################################

Write-Host "Test for WDS"
Import-Module ServerManager -ErrorAction SilentlyContinue
if ( -not ( get-windowsfeature -Name WDS | Where-Object InstallState -eq Available ) )
{

    Write-Host "Quick Configure WDS"
    wdsutil /initialize-server /reminst:c:\RemoteInstall
    WDSUTIL /Set-Server /AnswerClients:All

}

#endregion

#region XXXXX
#######################################

Write-Host "XXX"
cmd.exe /c echo hello world!

#endregion

