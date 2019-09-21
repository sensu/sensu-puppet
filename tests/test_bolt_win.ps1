#$env:PATH += ";C:\Program Files\sensu\sensu-agent\bin"
$env:PATH += ";C:\Program Files\Puppet Labs\Puppet\bin"
#iex 'sensu-agent.exe service uninstall'
#iex 'puppet resource package "Sensu Agent" ensure=absent'
iex "puppet module install puppetlabs-chocolatey"
iex "puppet apply -e 'include ::chocolatey'"
$env:PATH += ";C:\ProgramData\chocolatey\bin"
iex "choco install -y puppet-bolt"
$env:PATH += ";C:\Program Files\Puppet Labs\Bolt\bin"
iex 'bolt task run sensu::install_agent backend=sensu-backend.example.com:8081 subscription=windows --nodes localhost --modulepath C:/ProgramData/PuppetLabs/code/environments/production/modules'
