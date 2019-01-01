# Variables
$log = "C:/vagrant/puppet-agent.log"
$agent_url = "https://downloads.puppetlabs.com/windows/puppet5/puppet-agent-5.5.6-x64.msi"
if ( Get-Command "puppet" -ErrorAction SilentlyContinue ) {
  Write-Output "Puppet is already installed.  Skipping install of $agent_url"
} else {
  Write-Output "Installing Puppet from $agent_url"
  Write-Output "Log will be written to $log"
  if ( Test-Path $log ) { Remove-Item $log }
  # Install puppet
  Start-Process msiexec.exe -Wait -NoNewWindow -ArgumentList @("/i", "$agent_url", "/qn", "/l*", "$log")
}
