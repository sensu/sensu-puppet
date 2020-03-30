$env:PATH += ";C:\Program Files\Puppet Labs\Puppet\bin"
iex "puppet module install puppetlabs-chocolatey"
iex "puppet apply -e 'include ::chocolatey'"
$env:PATH += ";C:\ProgramData\chocolatey\bin"
iex "choco install -y puppet-bolt"
$env:PATH += ";C:\Program Files\Puppet Labs\Bolt\bin"
iex 'bolt task show'
iex 'bolt task run sensu::install_agent backend=sensu-backend.example.com:8081 subscription=windows --targets localhost --modulepath C:\ProgramData\PuppetLabs\code\environments\production\modules'
