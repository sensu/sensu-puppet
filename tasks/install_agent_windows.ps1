[CmdletBinding()]
Param(
  [Parameter(Mandatory = $True)] [String] $Backend,
  [Parameter(Mandatory = $True)] [String] $Subscription,
  [Parameter(Mandatory = $False)] [String] $Entity_name = "$env:computername.$env:userdnsdomain",
  [Parameter(Mandatory = $False)] [String] $Namespace = "default",
  [Parameter(Mandatory = $False)] [Bool] $Output = $False
)

$Package_source = "https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.13.1/sensu-go-agent_5.13.1.5957_en-US.x64.msi"

$env:PATH += ";C:\Program Files\Puppet Labs\Puppet\bin"

$return_output = @{}

# Install modules
$module_output1 = iex "puppet module install sensu-sensu --color false"
$module_output2 = iex "puppet module install richardc-datacat --color false"
$module_output2 = iex "puppet module install puppet-archive --color false"
$module_install_output = $module_output1 + $module_output2
$return_output.Add("module-install", $($module_install_output -Split "`n").TrimEnd("`r"))

# Create Puppet manifest in Temp space
$MANIFEST = [System.IO.Path]::GetTempFileName()
$manifest_content = @"
class { '::sensu':
  use_ssl => false,
}
class { 'sensu::agent':
  package_source => '$Package_source',
  backends       => ['$Backend'],
  subscriptions  => ['$Subscription'],
  entity_name    => '$Entity_name',
  namespace      => '$Namespace',
}
"@

$return_output.Add("manifest", $($manifest_content -Split "`n").TrimEnd("`r"))
$manifest_content | Out-File -FilePath $MANIFEST -Encoding ascii
$manifest_content = Get-Content -Path $MANIFEST

# Apply manifest that installs Sensu Go Agent
$output_apply = iex "puppet apply $MANIFEST --color false 2>&1"
$return_output.Add("apply", $($output_apply -Split "`n").TrimEnd("`r"))

Remove-Item -Path $MANIFEST

$return = @{
status = "install agent successful"
}
if ($Output -eq $True) { $return.Add("output", $return_output) }
ConvertTo-Json -InputObject $return -Compress
