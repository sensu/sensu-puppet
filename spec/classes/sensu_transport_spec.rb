require 'spec_helper'
require 'json'

describe 'sensu' do
  let(:facts) {{
    :fqdn     => 'testhost.example.com',
    :osfamily => 'RedHat',
    :kernel   => 'Linux',
  }}

  context 'transports' do
    context 'defaults' do
      it { should create_class('sensu::transport') }
      it 'uses rabbitmq with reconnect on error' do
        should contain_file('/etc/sensu/conf.d/transport.json').with_content(
          JSON.pretty_generate({'transport' => {'name' => 'rabbitmq', 'reconnect_on_error' => true}})
        )
      end
    end

    describe 'when transport_reconnect_on_error is false' do
      let(:params) do
        {transport_reconnect_on_error: false}
      end

      it { should create_class('sensu::transport') }
      it { should contain_file('/etc/sensu/conf.d/transport.json').with_content(
        JSON.pretty_generate({'transport' => {'name' => 'rabbitmq', 'reconnect_on_error' => false}})
      )}
    end

    context 'setting redis as transport' do
      let(:params) {{
        :transport_type => 'redis'
      }}

      it { should create_class('sensu::transport') }
      it { should contain_file('/etc/sensu/conf.d/transport.json').with_content(
        JSON.pretty_generate({'transport' => {'name' => 'redis', 'reconnect_on_error' => true}})
      )}
    end

    context 'setting rabbitmq as transport' do
      let(:params) {{
        :transport_type => 'rabbitmq'
      }}

      it { should create_class('sensu::transport') }
      it { should contain_file('/etc/sensu/conf.d/transport.json').with_content(
        JSON.pretty_generate({'transport' => {'name' => 'rabbitmq', 'reconnect_on_error' => true}})
      )}
    end
  end
end
