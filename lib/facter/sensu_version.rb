Facter.add(:sensu_version) do
  sensu_agent = nil
  if File.exists? 'C:\opt\sensu\embedded\bin\sensu-agent.bat'
    sensu_agent = 'C:\opt\sensu\embedded\bin\sensu-agent.bat'
  else
    sensu_agent = Facter::Util::Resolution.which('sensu-agent')
  end
  setcode do
    if sensu_agent
      output = Facter::Util::Resolution.exec("#{sensu_agent} version 2>&1")
      if output =~ /^sensu-agent version ([^,]+)/
        $1
      end
    end
  end
end
