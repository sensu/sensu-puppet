[CmdletBinding()]
Param(
  [Parameter(Mandatory = $True)] [String] $Backend,
  [Parameter(Mandatory = $True)] [String] $Subscription,
  [Parameter(Mandatory = $False)] [String] $Namespace = "default"
)

$Package_source = "https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.13.1/sensu-go-agent_5.13.1.5957_en-US.x64.msi"

$env:PATH += ";C:\Program Files\Puppet Labs\Puppet\bin"

$output = iex "puppet module install sensu-sensu"
Write-Output $output
$output = iex "puppet module install puppet-archive"
Write-Output $output

#$MANIFEST = [System.IO.Path]::GetTempFileName()
$MANIFEST = "C:/manifest.pp"
Write-Output $MANIFEST
$manifest_content = @"
class { '::sensu':
  use_ssl => false,
}
class { '::sensu::agent':
  package_source => '$Package_source',
  backends       => ['$Backend'],
  config_hash    => {
    'subscriptions' => ['$Subscription'],
    'namespace'     => '$Namespace',
  },
}
"@

$manifest_content | Out-File -FilePath $MANIFEST -Encoding ascii
$manifest_content = Get-Content -Path $MANIFEST
Write-Output $manifest_content

Write-Output "Execute: puppet apply $MANIFEST"
$output = iex "puppet apply -v --debug --trace $MANIFEST 2>&1"
$output | Out-File -FilePath C:\output
Write-Output $output

Remove-Item -Path $MANIFEST

$return = @{
status = "install agent successful"
}
ConvertTo-Json -InputObject $return -Compress

