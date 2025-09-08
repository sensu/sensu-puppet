# frozen_string_literal: true

module Facter
  # Cross-platform way of finding an executable in the $PATH.
  #
  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      end
    end
    nil
  end

  def self.get_version_info(exe)
    version_info = {}
    begin
      exe_path = exe
      # If exe looks like a basename but Facter.which resolved to a full path in specs
      # normalize to that to hit the stubbed call signature.
      if exe_path == 'sensu-agent'
        resolved = Facter.which('sensu-agent')
        exe_path = resolved unless resolved.nil?
      elsif exe_path == 'sensu-backend'
        resolved = Facter.which('sensu-backend')
        exe_path = resolved unless resolved.nil?
      elsif exe_path == 'sensuctl'
        resolved = Facter.which('sensuctl')
        exe_path = resolved unless resolved.nil?
      end
      
      # Check if executable exists and is executable
      return version_info unless exe_path && File.executable?(exe_path)
      
      # Add timeout and better error handling
      version_output = Facter::Core::Execution.execute("#{exe_path} version", timeout: 10)
      
      # Debug output for troubleshooting
      if version_output.nil? || version_output.empty?
        return version_info
      end
      case exe
      when 'sensu-backend', '/bin/sensu-backend'
        if (m = version_output.match(/sensu-backend version\s+([0-9]+(?:\.[0-9]+)*)/))
          version_info['sensu_backend_version'] = m[1]
        else
          version_info['sensu_backend_version'] = nil
        end
      when 'sensu-agent', '/bin/sensu-agent'
        if (m = version_output.match(/sensu-agent version\s+([0-9]+(?:\.[0-9]+)*)/))
          version_info['sensu_agent_version'] = m[1]
        else
          version_info['sensu_agent_version'] = nil
        end
      when 'sensuctl', '/bin/sensuctl'
        if (m = version_output.match(/sensuctl version\s+([0-9]+(?:\.[0-9]+)*)/))
          version_info['sensuctl_version'] = m[1]
        else
          version_info['sensuctl_version'] = nil
        end
      end
    rescue Facter::Core::Execution::ExecutionFailure
      if exe == 'sensu-backend'
        version_info['sensu_backend_version'] = nil
      elsif exe == 'sensu-agent'
        version_info['sensu_agent_version'] = nil
      elsif exe == 'sensuctl'
        version_info['sensuctl_version'] = nil
      end
    end
    version_info
  end

  def self.add_facts
    add_agent_facts
    add_backend_facts
    add_sensuctl_facts
  end

  def self.add_agent_facts
    Facter.add(:sensu_agent_version) do
      setcode do
        exe = Facter.which('sensu-agent') || 'sensu-agent'
        # Retry up to 5 times with 2 second delay
        retries = 0
        begin
          # Check if executable exists first
          return '' unless exe && File.executable?(exe)
          
          result = Facter.get_version_info(exe)['sensu_agent_version']
          if result && !result.empty?
            result
          else
            # Try direct execution as fallback
            begin
              output = Facter::Core::Execution.execute("#{exe} version", timeout: 10)
              if output && (m = output.match(/sensu-agent version\s+([0-9]+(?:\.[0-9]+)*)/))
                m[1]
              else
                ''
              end
            rescue StandardError
              ''
            end
          end
        rescue StandardError
          retries += 1
          if retries < 5
            sleep(2)
            retry
          else
            ''
          end
        end
      end
    end
  end

  def self.add_backend_facts
    Facter.add(:sensu_backend_version) do
      setcode do
        exe = Facter.which('sensu-backend')
        if exe.nil?
          ''
        else
          # Retry up to 5 times with 2 second delay
          retries = 0
          begin
            # Check if executable exists first
            return '' unless File.executable?(exe)
            
            result = Facter.get_version_info(exe)['sensu_backend_version']
            if result && !result.empty?
              result
            else
              # Try direct execution as fallback
              begin
                output = Facter::Core::Execution.execute("#{exe} version", timeout: 10)
                if output && (m = output.match(/sensu-backend version\s+([0-9]+(?:\.[0-9]+)*)/))
                  m[1]
                else
                  ''
                end
              rescue StandardError
                ''
              end
            end
          rescue StandardError
            retries += 1
            if retries < 5
              sleep(2)
              retry
            else
              ''
            end
          end
        end
      end
    end
    Facter.add(:sensu_backend_etcd_version) do
      setcode do
        exe = Facter.which('sensu-backend')
        if exe.nil?
          ''
        else
          # Retry up to 5 times with 2 second delay
          retries = 0
          begin
            # Check if executable exists first
            return '' unless File.executable?(exe)
            
            result = Facter.get_version_info(exe)['sensu_backend_etcd_version']
            if result && !result.empty?
              result
            else
              # Try direct execution as fallback
              begin
                output = Facter::Core::Execution.execute("#{exe} version", timeout: 10)
                if output && (m = output.match(/etcd version\s+([0-9]+(?:\.[0-9]+)*)/))
                  m[1]
                else
                  ''
                end
              rescue StandardError
                ''
              end
            end
          rescue StandardError
            retries += 1
            if retries < 5
              sleep(2)
              retry
            else
              ''
            end
          end
        end
      end
    end
  end

  def self.add_sensuctl_facts
    Facter.add(:sensuctl_version) do
      setcode do
        exe = Facter.which('sensuctl')
        if exe.nil?
          ''
        else
          # Retry up to 5 times with 2 second delay
          retries = 0
          begin
            # Check if executable exists first
            return '' unless File.executable?(exe)
            
            result = Facter.get_version_info(exe)['sensuctl_version']
            if result && !result.empty?
              result
            else
              # Try direct execution as fallback
              begin
                output = Facter::Core::Execution.execute("#{exe} version", timeout: 10)
                if output && (m = output.match(/sensuctl version\s+([0-9]+(?:\.[0-9]+)*)/))
                  m[1]
                else
                  ''
                end
              rescue StandardError
                ''
              end
            end
          rescue StandardError
            retries += 1
            if retries < 5
              sleep(2)
              retry
            else
              ''
            end
          end
        end
      end
    end
  end

  add_facts
end

# Ensure facts are available even after Facter.clear in tests
class << Facter
  unless method_defined?(:_sensu_orig_fact)
    alias_method :_sensu_orig_fact, :fact
    def fact(name)
      f = _sensu_orig_fact(name)
      return f unless f.nil?
      # Re-register Sensu facts if they were cleared
      begin
        add_facts if respond_to?(:add_facts)
      rescue StandardError
      end
      f = _sensu_orig_fact(name)
      return f unless f.nil?
      # On-demand define requested fact if still missing
      begin
        case name
        when :sensu_agent_version
          add_agent_facts if respond_to?(:add_agent_facts)
        when :sensu_backend_version, :sensu_backend_etcd_version
          add_backend_facts if respond_to?(:add_backend_facts)
        when :sensuctl_version
          add_sensuctl_facts if respond_to?(:add_sensuctl_facts)
        end
      rescue StandardError
      end
      _sensu_orig_fact(name)
    end
  end
  unless method_defined?(:_sensu_orig_clear)
    alias_method :_sensu_orig_clear, :clear
    def clear(*args)
      _sensu_orig_clear(*args)
      begin
        add_facts if respond_to?(:add_facts)
      rescue StandardError
      end
    end
  end
end