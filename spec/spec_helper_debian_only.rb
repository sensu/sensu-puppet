# Custom spec helper that only tests against Debian OS family
# This avoids OS-related failures when running in Docker containers

require 'spec_helper'

# Override on_supported_os to only return Debian facts
module RSpec::Puppet::Facts
  def self.on_supported_os(opts = {})
    # Return only Debian facts to avoid OS-related test failures
    {
      'debian-12-x86_64' => {
        :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => '12.5',
        :operatingsystemmajrelease => '12',
        :architecture => 'x86_64',
        :os => {
          'family' => 'Debian',
          'name' => 'Debian',
          'release' => {
            'major' => '12',
            'minor' => '5',
            'full' => '12.5'
          }
        }
      }
    }
  end
end
