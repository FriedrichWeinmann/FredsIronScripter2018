﻿# Add all things you want to run after importing the main code

# Load Configurations
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\configurations\*.ps1")) {
	. Import-ModuleFile -Path $file.FullName
}

# Load Tab Expansion
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\tepp\*.ps1" -ErrorAction Ignore))
{
	. Import-ModuleFile -Path $file.FullName
}

# Load license data into the license framework
. Import-ModuleFile "$ModuleRoot\internal\scripts\license.ps1"