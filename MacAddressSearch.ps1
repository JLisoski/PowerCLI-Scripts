Connect-VIServer -Server #FQDN

$address = "00:00:00:00:00:00"

# Search for the address in VMHosts and VMs
$vmHosts = Get-VMHost | Get-VMHostNetworkAdapter | Where-Object { $_.Mac -eq $address -or $_.PortWorldWideName -eq $address }
$vmGuests = Get-VM | Get-NetworkAdapter | Where-Object { $_.MacAddress -eq $address -or $_.PortWorldWideName -eq $address }

if ($vmHosts) {
   Write-Host "Found the network hardware address on the following VMHosts:"
   $vmHosts | ForEach-Object {
       $vmHost = $_.VMHost
       $vm = Get-VM | Get-NetworkAdapter | Where-Object { $_.VM -eq $vmHost -and ($_.MacAddress -eq $address -or $_.PortWorldWideName -eq $address) } | Select-Object VM
       $_ | Add-Member -NotePropertyName "VM" -NotePropertyValue $vm.VM
       $_
   }
} else {
   Write-Host "Network hardware address not found on any VMHosts."
}

if ($vmGuests) {
   Write-Host "Found the network hardware address on the following VMs:"
   $vmGuests | ForEach-Object {
       $vm = $_.VM
       $_ | Add-Member -NotePropertyName "VM" -NotePropertyValue $vm
       $_
   }
} else {
   Write-Host "Network hardware address not found on any VMs."
}

# Disconnect from vCenter Server
Disconnect-VIServer -Server #FQDN -Confirm:$false
