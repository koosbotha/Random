Param($ResourceGroupName, $VMName)
#Start Logging
Write-Output "Starting Powershell update $(Get-date)" 
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
$vm.LicenseType = 'Windows_Server'
Write-Output "Target VM: $($Vm.Name)"
$tags = (Get-AzResource -ResourceId $vm.id).Tags
if (-not($tags.ContainsKey('Created by')))
{
Write-Output "Searching Activity log for Creator..." 
$tags.'Created by'=(((Get-AzActivityLog -ResourceId $vm.Id |`
 ?{$_.OperationName.Value -eq 'Microsoft.Compute/virtualMachines/write' `
 -and $_.SubStatus.value -eq 'Created'} ) | select -first 1).Caller -split '@' )[0]
$tags.'Remediated'=(Get-Date)
}
Update-AzVM -VM $vm -ResourceGroupName $ResourceGroupName
Update-AzTag -ResourceId $vm.id -Tag $tags -Operation Merge
Write-Output "...Deployment Script complete," 


















