function Get-FISMonitor
{
<#
	.SYNOPSIS
		Gathers information on the target's monitors.
	
	.DESCRIPTION
		This function uses CIM to gather information about the target computer(s)'s monitors.
	
	.PARAMETER ComputerName
		The computer to gather information on.
		Can be an established CimSession, which will then be reused.
	
	.PARAMETER Credential
		The credentials to use to gather information.
		This parameter is ignored for local queries.
	
	.PARAMETER Authentication
		The authentication method to use to gather the information.
		Uses the system default settings by default.
		This parameter is ignored for local queries.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Get-FISMonitor
	
		Returns monitor information on the local computer.
	
	.EXAMPLE
		PS C:\> Get-Content servers.txt | Get-FISMonitor
	
		Returns monitor information on all computers listed in servers.txt
	
	.EXAMPLE
		PS C:\> Get-ADComputer -Filter "name -like 'Desktop*'" | Get-FISMonitor
	
		Returns monitor information on all computers in ad whose name starts with "Desktop"
#>
	[OutputType([Fred.IronScripter2018.Monitor])]
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline = $true)]
		[PSFComputer[]]
		$ComputerName = $env:COMPUTERNAME,
		
		[System.Management.Automation.CredentialAttribute()]
		[System.Management.Automation.PSCredential]
		$Credential,
		
		[Microsoft.Management.Infrastructure.Options.PasswordAuthenticationMechanism]
		$Authentication = [Microsoft.Management.Infrastructure.Options.PasswordAuthenticationMechanism]::Default,
		
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
					if ($Computer.Type -like "CimSession") { $session = $Computer.InputObject }
					else { $session = New-CimSession -ComputerName $Computer -Credential $Credential -Authentication $Authentication -ErrorAction Stop }
					$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $session -ErrorAction Stop
					$bios = Get-CimInstance -ClassName Win32_Bios -CimSession $session -ErrorAction Stop
					$monitors = Get-CimInstance -ClassName wmiMonitorID -Namespace root\wmi -CimSession $session -ErrorAction Stop
					if ($Computer.Type -notlike "CimSession") { Remove-CimSession -CimSession $session }
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
				$object = New-Object Fred.IronScripter2018.Monitor -Property @{
					ComputerName   = $computerSystem.Name
					ComputerType   = $computerSystem.Model
					ComputerSerial = $bios.SerialNumber
					MonitorSerial  = ($monitor.SerialNumberID | Where-Object { $_ } | ForEach-Object { [char]$_ }) -join ""
					MonitorType    = ($monitor.UserFriendlyName | Where-Object { $_ } | ForEach-Object { [char]$_ }) -join ""
				}
				
				Write-PSFMessage -Level Verbose -Message "[$Computer] Processing $($object.MonitorType)" -Target $Computer -Tag 'monitor','processing','gathered'
				$object
			}
		}
		#endregion Process by Computer Name
	}
	end
	{
	
	}
}