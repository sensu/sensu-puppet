#!/opt/puppetlabs/puppet/bin/ruby
require 'resolv'
require 'json'
require 'open3'

class SensuBackendUpgrade
  def self.upgrade(params)
    cmd = ['sensu-backend', 'upgrade', '--skip-confirm']
    valid_params = [
      'config_file', 'timeout', 'etcd_advertise_client_urls', 'etcd_cert_file',
      'etcd_cipher_suites', 'etcd_client_cert_auth', 'etcd_client_urls',
      'etcd_key_file', 'etcd_max_request_bytes', 'etcd_trusted_ca_file',
    ]
    params.each_pair do |key, value|
      next unless valid_params.include?(key.to_s)
      cmd << "--#{key.to_s.gsub('_', '-')}"
      if [TrueClass, FalseClass].include?(value.class)
        next
      elsif value.is_a?(Array)
        cmd << value.join(' ')
      else
        cmd << value
      end
    end
    stdout, stderr, status = Open3.capture3(cmd.join(' '))
    if status != 0
      raise Exception, "Failed to execute #{cmd.join(' ')}: #{stderr}"
    end
    logs = []
    stderr.each_line do |line|
      log = JSON.parse(line)
      logs << log
    end
    logs
  end

  def self.run
    params = JSON.parse(STDIN.read)
    logs = upgrade(params)
    puts({ logs: logs}.to_json)
  rescue Exception => e
    puts({ _error: e.message }.to_json)
    exit 1
  end
end

SensuBackendUpgrade.run if $PROGRAM_NAME == __FILE__

