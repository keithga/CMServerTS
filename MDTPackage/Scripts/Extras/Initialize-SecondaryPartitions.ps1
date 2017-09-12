<#

How do you configure Secondary Partitions?!?!

to do:

Initialize Disks if not already initialized.
Mark as writable
Create Storage Spaces
Format (NTFS vs REFS)
Volume Names?!?!

Make it all dynamic
Assign variables to each partition created.

 Get-Disk | Where-Object operationalstatus -ne Online | set-Disk -IsOffline $False



#>

[cmdletbinding()]
param()

get-disk | where number -ne 0 | where-Object { $_.SIze - $_.AllocatedSize -gt 200GB } | write-host

