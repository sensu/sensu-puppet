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

if ( $PSVersionTable.PSVersion.Major -ge 5 ) {
  Write-Output "Powershell version already 5+"
} else {
  $download = "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu"
  $output = "C:/Win8.1AndW2K12R2-KB3191564-x64.msu"
  #Invoke-WebRequest -Uri $download -OutFile $output
  (New-Object System.Net.WebClient).DownloadFile($download, $output)
  cmd /c wusa.exe $output /quiet /norestart
}

