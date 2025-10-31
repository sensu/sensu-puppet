# frozen_string_literal: true

module Facter
  def self.add_sensuctl_facts
    Facter.add(:sensuctl_version) do
      setcode do
        exe = Facter.which('sensuctl')
        exe.nil? ? nil : Facter.get_version_info(exe)['sensuctl_version']
      end
    end
  end

  def self.get_version_info(exe)
    version_info = {}
    begin
      exe_path = exe
      version_output = Facter::Core::Execution.execute("#{exe_path} version", timeout: 10)
      case exe
      when 'sensuctl', '/bin/sensuctl'
        if (m = version_output.match(/sensuctl version\s+([0-9.]+)/))
          version_info['sensuctl_version'] = m[1]
        else
          version_info['sensuctl_version'] = nil
        end
      end
    rescue Facter::Core::Execution::ExecutionFailure
      version_info['sensuctl_version'] = nil
    end
    version_info
  end

  add_sensuctl_facts
end
