# Variables
$log = "C:/vagrant/puppet-agent.log"
$agent_url = "https://s3.amazonaws.com/puppet-agents/2017.2/puppet-agent/1.10.4/repos/windows/puppet-agent-1.10.4-x64.msi"
# Install puppet
Write-Output "Installing Puppet from $agent_url"
Remove-Item $log
Start-Process msiexec.exe -ArgumentList @("/i", "$agent_url", "/passive", "/qn", "/l*", "$log") -wait
