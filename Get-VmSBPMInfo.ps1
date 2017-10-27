<# 
Get-vm-details
.Description
    Get virtual machine SBPM info
	russ 02/05/2016
    
.Example
    ./Get-VmSbpmInfo.ps1

#>

	
# Set file path, filename, date and time
# This is my standard path, you should adjust as needed
$filepath = "C:\PowerCLI\Output\"
$filename = "vm-sbpm-info"
$initalTime = Get-Date
$date = Get-Date ($initalTime) -uformat %Y%m%d
$time = Get-Date ($initalTime) -uformat %H%M

Write-Host "This will provide a list of storage based polices attached to virtual machines" -ForegroundColor Blue


Write-Host "---------------------------------------------------------" -ForegroundColor DarkYellow
Write-Host "Output will be saved to:"  								   -ForegroundColor Yellow
Write-Host $filepath$filename-$date$time".csv"  					   -ForegroundColor White
Write-Host "---------------------------------------------------------" -ForegroundColor DarkYellow

# Create empty results array to hold values
$resultsarray =@()

#Collect vms
$vms = Get-VM 

# Iterates each vm in the $vms variable
foreach ($vm in $vms){ 
	          
        write-output "Collecting info for: $($vm.Name)"
					
		# Create an array object to hold results, and add data as attributes using the add-member commandlet
		$resultObject = new-object PSObject
     
		$Storagepolicy = Get-vm $vm | Get-SpbmEntityConfiguration
		$resultObject | add-member -membertype NoteProperty -name "Storage Policy" -Value  $Storagepolicy.StoragePolicy.name
		$resultObject | add-member -membertype NoteProperty -name "Compliance Status" -Value  $Storagepolicy.ComplianceStatus
		$resultObject | add-member -membertype NoteProperty -name "Time of check" -Value  $Storagepolicy.TimeOfCheck	
		$resultObject | add-member -membertype NoteProperty -name "Name" -Value $vm.Name
		$resultObject | add-member -membertype NoteProperty -name "PowerState" -Value $vm.PowerState		
		$resultObject | add-member -membertype NoteProperty -name "Folder" -Value $vm.Folder.Name	
		$resultObject | add-member -membertype NoteProperty -name "Datastore" -Value $vm.ExtensionData.Config.DatastoreUrl.Name
		$UsedSpace  = $vm.UsedSpaceGB -as [int]
		$resultObject | add-member -membertype NoteProperty -name "Used Disk" -Value $UsedSpace
		$ProvisionedSpace  = $vm.ProvisionedSpaceGB -as [int]
		$resultObject | add-member -membertype NoteProperty -name "Provisioned Space" -Value $ProvisionedSpace

		# Write array output to results 
		$resultsarray += $resultObject		

}

# output to gridview
$resultsarray | Out-GridView

# export to csv 
$resultsarray | Export-Csv $filepath$filename"-"$datacenter$cluster"-"$date$time".csv" -NoType