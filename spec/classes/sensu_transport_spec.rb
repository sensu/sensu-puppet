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

    context 'setting transport_type to redis' do
      let(:params) {{
        :transport_type => 'redis',
      }}

      it { should contain_file('/etc/sensu/conf.d/transport.json').with_content(
        JSON.pretty_generate({'transport' => {'name' => 'redis', 'reconnect_on_error' => true}})
      )}
    end
  end
end

