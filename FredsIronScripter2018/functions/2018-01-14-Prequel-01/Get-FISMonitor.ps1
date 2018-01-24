function Get-FISMonitor
{
<#
	.SYNOPSIS
		Gathers information on the target's monitors.
	
	.DESCRIPTION
		This function uses CIM to gather information about the target computer(s)'s monitors.
	
	.PARAMETER ComputerName
		The computer to gather information on.
	
	.PARAMETER Credential
		The credentials to use to gather information.
		This parameter is ignored for local queries.
	
	.PARAMETER Authentication
		The authentication method to use to gather the information.
		Uses the system default settings by default.
		This parameter is ignored for local queries.
	
	.PARAMETER CimSession
		Reuse an already established CimSession.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Get-FISMonitor
	
		Returns monitor information on the local computer.
	
	.EXAMPLE
		PS C:\> Get-Content servers.txt | Get-FISMoonitor
	
		Returns monitor information on all computers listed in servers.txt
	
	.EXAMPLE
		PS C:\> Get-ADComputer -Filter "name -like 'Desktop*'" | Get-FISMonitor
	
		Returns monitor information on all computers in ad whose name starts with "Desktop"
#>
	[CmdletBinding(DefaultParameterSetName = 'ComputerName')]
	Param (
		[Parameter(ValueFromPipeline = $true, ParameterSetName = 'ComputerName')]
		[PSFComputer[]]
		$ComputerName = $env:COMPUTERNAME,
		
		[System.Management.Automation.CredentialAttribute()]
		[System.Management.Automation.PSCredential]
		$Credential,
		
		[Microsoft.Management.Infrastructure.Options.PasswordAuthenticationMechanism]
		$Authentication = [Microsoft.Management.Infrastructure.Options.PasswordAuthenticationMechanism]::Default,
		
		[Parameter(ValueFromPipeline = $true, ParameterSetName = 'Session')]
		[Microsoft.Management.Infrastructure.CimSession[]]
		$CimSession,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -Message "Bound parameters: $($PSBoundParameters.Keys -join ', ')" -Tag 'debug'
	}
	process
	{
		#region Process by Computer Name
		foreach ($Computer in $ComputerName)
		{
			Write-PSFMessage -Level VeryVerbose -Message "[$Computer] Establishing connection" -Target $Computer -Tag 'connect', 'start'
			
			try
			{
				if (-not $Computer.IsLocalhost)
				{
					$session = New-CimSession -ComputerName $Computer -Credential $Credential -Authentication $Authentication -ErrorAction Stop
					$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $session -ErrorAction Stop
					$bios = Get-CimInstance -ClassName Win32_Bios -CimSession $session -ErrorAction Stop
					$monitors = Get-CimInstance -ClassName wmiMonitorID -Namespace root\wmi -CimSession $session -ErrorAction Stop
				}
				else
				{
					# No point in establishing a session to localhost, custom credentials also not supported
					$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
					$bios = Get-CimInstance -ClassName Win32_Bios -ErrorAction Stop
					$monitors = Get-CimInstance -ClassName wmiMonitorID -Namespace root\wmi -ErrorAction Stop
				}
			}
			catch
			{
				if ($_.CategoryInfo.Category -eq "NotImplemented")
				{
					Stop-PSFFunction -Message "[$Computer] Failed to execute, 'Not Implemented'. This usually happens when running the command against a server without monitor" -Target $Computer -Tag 'connect', 'fail' -ErrorRecord $_ -EnableException $EnableException -Continue -OverrideExceptionMessage
				}
				else
				{
					Stop-PSFFunction -Message "[$Computer] Failed to connect to target computer" -Target $Computer -Tag 'connect', 'fail' -ErrorRecord $_ -EnableException $EnableException -Continue
				}
			}
			
			foreach ($monitor in $monitors)
			{
				$object = [PSCustomObject]@{
					ComputerName  = $computerSystem.Name
					ComputerType   = $computerSystem.Model
					ComputerSerial = $bios.SerialNumber
					MonitorSerial  = ($monitor.SerialNumberID | Where-Object { $_ } | ForEach-Object { [char]$_ }) -join ""
					MonitorType = ($monitor.UserFriendlyName | Where-Object { $_ } | ForEach-Object { [char]$_ }) -join ""
				}
				
				Write-PSFMessage -Level Verbose -Message "[$Computer] Processing $($object.MonitorType)" -Target $Computer -Tag 'monitor','processing','gathered'
				$null = $object.PSObject.TypeNames.Insert(0, "Fred.IronScripter2018.Monitor")
				$object
			}
		}
		#endregion Process by Computer Name
		
		#region Process by CimSession
		foreach ($Session in $CimSession)
		{
			$sessionDisplayName = "{0} / {1}" -f $Session.Name, $Session.ComputerName
			Write-PSFMessage -Level VeryVerbose -Message "[$sessionDisplayName] Retrieving data" -Target $Session -Tag 'connect', 'start'
			
			try
			{
				$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $Session -ErrorAction Stop
				$bios = Get-CimInstance -ClassName Win32_Bios -CimSession $Session -ErrorAction Stop
				$monitors = Get-CimInstance -ClassName wmiMonitorID -Namespace root\wmi -CimSession $Session -ErrorAction Stop
			}
			catch
			{
				if ($_.CategoryInfo.Category -eq "NotImplemented")
				{
					Stop-PSFFunction -Message "[$sessionDisplayName] Failed to execute, 'Not Implemented'. This usually happens when running the command against a server without monitor" -Target $Session -Tag 'connect', 'fail' -ErrorRecord $_ -EnableException $EnableException -Continue -OverrideExceptionMessage
				}
				else
				{
					Stop-PSFFunction -Message "[$sessionDisplayName] Failed to gather data from target computer" -Target $Session -Tag 'connect', 'fail' -ErrorRecord $_ -EnableException $EnableException -Continue
				}
			}
			
			foreach ($monitor in $monitors)
			{
				$object = [PSCustomObject]@{
					ComputerName   = $computerSystem.Name
					ComputerType   = $computerSystem.Model
					ComputerSerial = $bios.SerialNumber
					MonitorSerial  = ($monitor.SerialNumberID | Where-Object { $_ } | ForEach-Object { [char]$_ }) -join ""
					MonitorType    = ($monitor.UserFriendlyName | Where-Object { $_ } | ForEach-Object { [char]$_ }) -join ""
				}
				
				Write-PSFMessage -Level Verbose -Message "[$sessionDisplayName] Processing $($object.MonitorType)" -Target $Session -Tag 'monitor', 'processing', 'gathered'
				$null = $object.PSObject.TypeNames.Insert(0, "Fred.IronScripter2018.Monitor")
				$object
			}
		}
		#endregion Process by CimSession
	}
	end
	{
	
	}
}