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

# Create the sensu module directory.  We only copy certain directories because
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
iex "puppet module install puppetlabs/stdlib --version 4.24.0"
iex "puppet module install lwf-remote_file --version 1.1.3"
iex "puppet module install puppetlabs/dsc --version 1.7.0"
iex "puppet module install puppetlabs/acl --version 2.1.0"
iex "puppet module install puppetlabs/powershell --version 2.2.0"
