# Variables
if ( Get-Command "puppet" -ErrorAction SilentlyContinue ) {
  Write-Output "Puppet is already installed."
} else {
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  # Install puppet
  iex "choco install puppet-agent --yes --version=5.5.19"
}

$hiera_file = "C:\ProgramData\PuppetLabs\puppet\etc\hiera.yaml"
$moduledir = "C:\ProgramData\PuppetLabs\code\environments\production\modules"
$vagrant = "C:\vagrant"
$hiera_content = @'
---
version: 5
hierarchy:
  - name: Common
    path: common.yaml
defaults:
  data_hash: yaml_data
  datadir: hieradata
'@

# Create the sensuclassic module directory.  We only copy certain directories because
New-Item -Path $moduledir -ItemType directory -Force | Out-Null
# Remove the link if it exists.  Remove-Item can't deal with links.
if ( Test-Path "$moduledir\sensu" ) { cmd /c rmdir "$moduledir\sensu" }
# Create a symbolic link.  Requires Powereshell 2.0 or greater.
cmd /c mklink /d "$moduledir\sensu" "$vagrant"

# Avoid deprecation warning (ASCII encoding avoids YAML UTF-8 error)
$hiera_content | Out-File -FilePath "$hiera_file" -Encoding ascii

# There are multiple power shell scripts.  The first installs Puppet, but
# puppet is not in the PATH.  The second invokes a new shell which will have
# Puppet in the PATH.
$env:PATH += ";C:\Program Files\Puppet Labs\Puppet\bin"
iex "puppet module install puppetlabs-stdlib"
iex "puppet module install puppetlabs-chocolatey"
iex "puppet module install puppet-archive"
iex "puppet module install puppet-windows_env"
iex "puppet module install richardc-datacat"
New-Item -Path "C:\ProgramData\PuppetLabs\puppet\etc\ssl" -ItemType directory -Force | Out-Null
Copy-Item -Path "C:\vagrant\tests\ssl\*" -Destination "C:\ProgramData\PuppetLabs\puppet\etc\ssl\" -Recurse -Force

iex "puppet resource host sensu-backend.example.com ensure=present ip=192.168.52.10 host_aliases=sensu-backend"
iex "puppet config set --section main certname sensu-agent"
