[CmdletBinding()]
Param(
  [Parameter(Mandatory = $True)] [String] $Backend,
  [Parameter(Mandatory = $True)] [String] $Subscription,
  [Parameter(Mandatory = $False)] [String] $Namespace = "default"
)

$Package_source = "https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.13.1/sensu-go-agent_5.13.1.5957_en-US.x64.msi"

$env:PATH += ";C:\Program Files\Puppet Labs\Puppet\bin"

$output = iex "puppet module install sensu-sensu"
$output = iex "puppet module install puppet-archive"

$MANIFEST = [System.IO.Path]::GetTempFileName()
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

$output = iex "puppet apply $MANIFEST"

Remove-Item -Path $MANIFEST

ConvertTo-Json -InputObject @{"status" = "install agent successful"} -Compress

