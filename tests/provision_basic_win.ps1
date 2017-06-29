# Variables
$log = "C:/vagrant/puppet-agent.log"
$agent_url = "https://s3.amazonaws.com/puppet-agents/2017.2/puppet-agent/1.10.4/repos/windows/puppet-agent-1.10.4-x64.msi"
if ( Get-Command "puppet" -ErrorAction SilentlyContinue ) {
  Write-Output "Puppet is already installed.  Skipping install of $agent_url"
} else {
  Write-Output "Installing Puppet from $agent_url"
  Write-Output "Log will be written to $log"
  if ( Test-Path $log ) { Remove-Item $log }
  # Install puppet
  Start-Process msiexec.exe -Wait -NoNewWindow -ArgumentList @("/i", "$agent_url", "/qn", "/l*", "$log")
}
