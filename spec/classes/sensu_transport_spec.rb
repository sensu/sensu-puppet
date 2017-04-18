require 'spec_helper'
require 'json'

describe 'sensu' do
  let(:facts) {{
    :fqdn     => 'testhost.example.com',
    :osfamily => 'RedHat',
  }}

  context 'transports' do
    context 'defaults' do
      it { should create_class('sensu::transport') }
      it { should contain_file('/etc/sensu/conf.d/transport.json') }
    end

    context 'setting version < 0.19.0' do
      let(:params) {{
        :version        => '0.9.10',
        :transport_type => 'redis',
      }}

      it { should contain_file('/etc/sensu/conf.d/transport.json').with_content(
        JSON.pretty_generate({'transport' => {'name' => 'rabbitmq', 'reconnect_on_error' => true}})
      )}
    end

    context 'setting version >= 0.19.0' do
      let(:params) {{
        :version        => '0.20.3',
        :transport_type => 'redis',
      }}

      it { should contain_file('/etc/sensu/conf.d/transport.json').with_content(
        JSON.pretty_generate({'transport' => {'name' => 'redis', 'reconnect_on_error' => true}})
      )}
    end
  end
end
