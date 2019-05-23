param(
	$sourceId,
	$managedEntityId,
	$computerName
)

try {
	function Write-Log([string]$Message) {
		$printDate = (get-date -F s)
		$script:traceLog += ("{0} | {1}" -f $printDate, $Message)
	}

	[string]$scriptName = $MyInvocation.MyCommand.Name
	[string]$scriptVersion = 'v1.00'
	[int]$evtID = 1337
	$script:traceLog = @()
	# type, 1=Error, 2=Warning, 4=Information
	[int]$EventType = 4
	
	Write-Log -Message ("ScriptVersion: [{0}], Running as: [{1}]" -f $scriptVersion, (whoami))
	Write-Log -Message ("Start discovery of 'Virtual Windows Server' with SourceID: [{0}] ManagedID: [{1}] Computername: [{2}]" -f $sourceId, $ManagedEntityId, $computerName)

    # GET INFO ABOUT HARDWARE
    $CIMData = Get-CimInstance -Query "SELECT Manufacturer,Model FROM Win32_ComputerSystem"
    Write-Log -Message ("Running on [{0}]" -f $CIMData.Manufacturer + " / " + $CIMData.Model)
    $isVirtual = $false
	# AND OS
	$OSVersion = (Get-CimInstance Win32_OperatingSystem).version

    # Create MOM Script API and Discoverydata
    Write-Log -Message "Creating MOM Object..."
    $Api = new-object -comObject 'MOM.ScriptAPI'
    Write-Log -Message "Creating DiscoveryDataObject..."
    $DiscoveryData = $Api.CreateDiscoveryData(0, $SourceId, $ManagedEntityId)

    switch -Wildcard ($CIMData.Manufacturer) {
        'VMWare*' {
            if ($CIMData.Model -like 'VMware Virtual Platform*') {
                $instance = $DiscoveryData.CreateClassInstance("$MPElement[Name='LOST.Virtual.Windows.VMWare.Computer.Class']$")
				$VirtualMachineType = 'VMWare'
                $isVirtual = $true
            }
            break
        }
        'Microsoft*' { 
            if ($CIMData.Model -like 'Virtual Machine*') {
                $instance = $DiscoveryData.CreateClassInstance("$MPElement[Name='LOST.Virtual.Windows.HyperV.Computer.Class']$")
				$VirtualMachineType = 'Hyper-V'
                $isVirtual = $true
            }
            break
        }
        'Xen*' {  
            if ($CIMData.Model -like 'HVM*') {
                $instance = $DiscoveryData.CreateClassInstance("$MPElement[Name='LOST.Virtual.Windows.Xen.Computer.Class']$")
				$VirtualMachineType = 'XEN'
				$isVirtual = $true
            }
            break
        }
        'QEMU*' { 
            if ($CIMData.Model -like 'Standard PC*') {
                $instance = $DiscoveryData.CreateClassInstance("$MPElement[Name='LOST.Virtual.Windows.ProxmoxVE.Computer.Class']$")
                $VirtualMachineType = 'ProxmoxVE'
				$isVirtual = $true
            }
            break
        }
        'innotek*' {  
            if ($CIMData.Model -like 'VirtualBox*') {
                $instance = $DiscoveryData.CreateClassInstance("$MPElement[Name='LOST.Virtual.Windows.VirtualBox.Computer.Class']$")
                $VirtualMachineType = 'VirtualBox'
				$isVirtual = $true
            }
            break
        }
        default{
            Write-Log -Message "Not running on a Hypervisor."
        }
    }
    if ($isVirtual) {
        Write-Log -Message "Adding properties and SCOM discovery instance."
        $instance.AddProperty("$MPElement[Name='LOST.Virtual.Windows.Computer.Class']/VirtualMachineType$", $VirtualMachineType)
		$instance.AddProperty("$MPElement[Name='LOST.Virtual.Windows.Computer.Class']/OSVersion$", $OSVersion)
		$instance.AddProperty("$MPElement[Name='Windows!Microsoft.Windows.Computer']/PrincipalName$", $ComputerName)
        $instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $ComputerName)
        $DiscoveryData.AddInstance($instance)
		$DiscoveryData
    }
}
catch {
	Write-Log -Message ("Error!`n $_ `n")
	$EventType = 1
}
finally {
	Write-Log ("'Virtual Windows Server' discovery is finished.")
	$api.LogScriptEvent($scriptName, $evtID, $EventType, "`n$($script:traceLog | Out-String)")
}