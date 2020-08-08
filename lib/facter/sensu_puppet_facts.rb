require 'puppet'

module SensuPuppetFacts
  def self.add_facts
    SensuPuppetFacts.init_settings
    Facter.add(:puppet_hostcert) do
      setcode do
        ::Puppet[:hostcert].to_s
      end
    end

    Facter.add(:puppet_hostprivkey) do
      setcode do
        ::Puppet[:hostprivkey].to_s
      end
    end

    Facter.add(:puppet_localcacert) do
      setcode do
        ::Puppet[:localcacert].to_s
      end
    end

    Facter.add(:puppet_hostcrl) do
      setcode do
        ::Puppet[:hostcrl].to_s
      end
    end
  end

  def self.init_settings
    if ! ::Puppet.settings.global_defaults_initialized?
      ::Puppet.initialize_settings
    end
  end
end

SensuPuppetFacts.add_facts

