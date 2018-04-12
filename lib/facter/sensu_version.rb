Facter.add(:sensu_version) do
  case Facter.value(:kernel)
  when "windows" || "Windows"
    setcode do
      if File.exists? 'C:\opt\sensu\embedded\bin\sensu-client.bat'
        sensuversion = Facter::Util::Resolution.exec('C:\opt\sensu\embedded\bin\sensu-client.bat --version 2>&1')
      end
    end
  else
    setcode do
      if File.exists? '/opt/sensu/embedded/bin/sensu-client'
        sensuversion = Facter::Util::Resolution.exec('/opt/sensu/embedded/bin/sensu-client --version 2>&1')
      end
    end
  end
end
