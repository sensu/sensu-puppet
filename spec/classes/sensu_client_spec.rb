require 'spec_helper'

describe 'sensu', :type => :class do
  let(:facts) do
    {
      :ipaddress => '2.3.4.5',
      :fqdn      => 'host.domain.com',
      :osfamily  => 'RedHat',
      :kernel    => 'Linux',
    }
  end

  let(:title) { 'host.domain.com' }

  context 'with client (default)' do
    context 'config' do
      context 'defaults' do
        let(:params) { { :client => true } }
        it { should contain_sensu_client_config(title).with(
          :ensure        => 'present',
          :client_name   => 'host.domain.com',
          :address       => '2.3.4.5',
          :socket        => { 'bind' => '127.0.0.1', 'port' => 3030 },
          :subscriptions => [],
          :custom        => {},
          :http_socket   => {},
          :servicenow    => {},
          :ec2           => {},
          :chef          => {},
          :puppet        => {},
        ) }

        it { should contain_sensu_client_config(title).without_redact }
        it { should contain_sensu_client_config(title).without_deregister }
        it { should contain_sensu_client_config(title).without_deregistration }
      end # defaults

      context 'setting config params' do
        let(:params_base) do
          {
            :client         => true,
            :client_address => '1.2.3.4',
            :subscriptions  => ['all'],
            :redact         => ['password'],
            :client_name    => 'myclient',
            :safe_mode      => true,
            :client_custom  => { 'bool' => true, 'foo' => 'bar' },
          }
        end
        let(:params_override) { {} }
        let(:params) { params_base.merge(params_override) }

        describe 'multiple attributes at once' do
          let(:params) { {
            :client                   => true,
            :client_address           => '1.2.3.4',
            :subscriptions            => ['all'],
            :redact                   => ['password'],
            :client_name              => 'myclient',
            :safe_mode                => true,
            :client_custom            => { 'bool' => true, 'foo' => 'bar' },
            :client_http_socket       => { 'bind' => '127.0.0.1', 'port' => 3031 },
            :client_servicenow        => { 'configuration_item' => { 'name' => 'Sample', 'os_version' => '6' } },
            :client_ec2               => { 'instance_id' => 'i-2131221' },
            :client_chef              => { 'nodename' => 'test' },
            :client_puppet            => { 'nodename' => 'test' },
          } }

          it { should contain_sensu_client_config(title).with( {
            :ensure        => 'present',
            :client_name   => 'myclient',
            :address       => '1.2.3.4',
            :socket        => { 'bind' => '127.0.0.1', 'port' => 3030 },
            :subscriptions => ['all'],
            :redact        => ['password'],
            :safe_mode     => true,
            :custom        => { 'bool' => true, 'foo' => 'bar' },
            :http_socket   => { 'bind' => '127.0.0.1', 'port' => 3031 },
            :servicenow    => { 'configuration_item' => { 'name' => 'Sample', 'os_version' => '6' } },
            :ec2           => { 'instance_id' => 'i-2131221' },
            :chef          => { 'nodename' => 'test' },
            :puppet        => { 'nodename' => 'test' },
          } ) }
        end

        describe 'deregister' do
          context '=> false' do
            let(:params_override) { {client_deregister: false} }
            it { is_expected.to contain_sensu_client_config(title).with(deregister: false) }
          end

          context '=> true' do
            let(:params_override) { {client_deregister: true} }
            it { is_expected.to contain_sensu_client_config(title).with(deregister: true) }
          end

          context '=> "garbage"' do
            let(:params_override) { {client_deregister: 'garbage'} }
            it { is_expected.to raise_error(Puppet::Error) }
          end
        end

        describe 'client_deregistration' do
          let(:params_override) { {client_deregistration: deregistration} }
          context "=> {'handler': 'deregister_client'}" do
            let(:deregistration) { {'handler' => 'deregister_client'} }
            it { is_expected.to contain_sensu_client_config(title).with(deregistration: deregistration) }
          end

          context "=> {}" do
            let(:deregistration) { {} }
            it { is_expected.to contain_sensu_client_config(title).with(deregistration: deregistration) }
          end

          context "=> 'absent' (error)" do
            let(:deregistration) { 'absent' }
            it { is_expected.to raise_error(Puppet::Error) }
          end
        end

        describe 'client_registration' do
          let(:params_override) { {client_registration: registration} }
          context "=> {'handler': 'register_client'}" do
            let(:registration) { {'handler' => 'register_client'} }
            it { is_expected.to contain_sensu_client_config(title).with(registration: registration) }
          end

          context "=> {}" do
            let(:registration) { {} }
            it { is_expected.to contain_sensu_client_config(title).with(registration: registration) }
          end

          context "=> 'absent' (error)" do
            let(:registration) { 'absent' }
            it { is_expected.to raise_error(Puppet::Error) }
          end
        end

        describe 'http_socket' do
          http_socket = {
            'bind' => '127.0.0.1',
            'port' => '3031',
            'user' => 'sensu',
            'password' => 'sensu'
          }
          context "=> {'http_socket' => 'custom hash'}" do
            let(:params_override) { {client_http_socket: http_socket} }
            it { is_expected.to contain_sensu_client_config(title).with(http_socket: http_socket) }
          end
        end

        describe 'servicenow' do
          servicenow = {
            'configuration_item' => {
              'name' => 'ServiceNow test',
              'os_version' => '16.04'
            }
          }
          context "=> {'servicenow' => 'custom hash'}" do
            let(:params_override) { {client_servicenow: servicenow} }
            it { is_expected.to contain_sensu_client_config(title).with(servicenow: servicenow) }
          end
        end

        describe 'ec2' do
          ec2 = {
            'instance-id' => 'i-424242',
            'allowed_instance_states' => [ 'pending','running','rebooting'],
            'region' => 'us-west-1',
            'access_key_id' => 'AlygD0X6Z4Xr2m3gl70J',
            'secret_access_key' => 'y9Jt5OqNOqdy5NCFjhcUsHMb6YqSbReLAJsy4d6obSZIWySv',
            'timeout' => '30',
          }
          context "=> {'ec2' => 'custom hash'}" do
            let(:params_override) { {client_ec2: ec2} }
            it { is_expected.to contain_sensu_client_config(title).with(ec2: ec2) }
          end
        end

        describe 'chef' do
          chef = {
            'nodename' => 'test',
            'endpoint' => 'https://api.chef.io/organizations/example',
            'flavor' => 'enterprise',
            'client' => 'sensu-server',
            'key' => '/etc/chef/i-424242.pem',
            'ssl_verify' => 'false',
            'proxy_address' => 'proxy.example.com',
            'proxy_port' => '8080',
            'proxy_username' => 'chef',
            'proxy_password' => 'secret',
            'timeout' => '30',
          }
          context "=> {'chef' => 'custom hash'}" do
            let(:params_override) { {client_chef: chef} }
            it { is_expected.to contain_sensu_client_config(title).with(chef: chef) }
          end
        end

        describe 'puppet' do
          puppet = {
            'nodename' => 'test',
          }
          context "=> {'puppet' => 'custom hash'}" do
            let(:params_override) { {client_puppet: puppet} }
            it { is_expected.to contain_sensu_client_config(title).with(puppet: puppet) }
          end
        end
      end

      context 'purge config' do
        let(:params) { { :purge => { 'config' => true } } }
        it { should contain_file('/etc/sensu/conf.d/client.json').with_ensure('present') }
      end # purge config
    end # config

    context 'service' do
      context 'default' do
        let(:params) { { :client => true } }
        it { should contain_service('sensu-client').with(
          :ensure     => 'running',
          :enable     => true,
          :hasrestart => true
        ) }
      end # default

      context 'not managing services' do
        let(:params) { {
          :client           => true,
          :manage_services  => false
        } }
        it { should_not contain_service('sensu-client') }
      end # not managing service

      context 'with hasrestart=false' do
        let(:params) { { :client => true, :hasrestart => false } }
        it { should contain_service('sensu-client').with(
          :ensure     => 'running',
          :enable     => true,
          :hasrestart => false
        ) }
      end # with hasrestart=false
    end #service
  end #with client

  context 'without client' do
    context 'config' do
      context 'purge config' do
        let(:params) { { :purge => { 'config' => true }, :client => false } }
        it { should contain_file('/etc/sensu/conf.d/client.json').with_ensure('absent') }
      end # purge config
    end # config

    context 'service' do
      context 'managing services' do
        let(:params) { { :client => false } }
        it { should contain_service('sensu-client').with(
          :ensure     => 'stopped',
          :enable     => false,
          :hasrestart => true
        ) }
      end # managing services

      context 'no client, not managing services' do
        let(:params) { {
          :client           => false,
          :manage_services  => false
        } }
        it { should_not contain_service('sensu-client') }
      end #no client, not managing services
    end # service
  end # without client
end
