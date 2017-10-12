require 'spec_helper'

rabbitmq_ssl_cert_chain_test = "-----BEGIN CERTIFICATE-----
MIIC3TCCAcWgAwIBAgIBAjANBgkqhkiG9w0BAQUFADASMRAwDgYDVQQDDAdTZW5z
dUNBMB4XDTE1MDMyNjE4MDMyM1oXDTIwMDMyNDE4MDMyM1owITEOMAwGA1UEAxMF
c2Vuc3UxDzANBgNVBAoTBmNsaWVudDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBANSIINiTUhqlfdICgfJWS5zbNI2LoSDM6+hdMaDxlJduHFGPjUuIiWkq
TmTSoS/mZts926Eh2KjheViIUmnjfbUOwELGJxFceOEBMVM04n18lDG9Pt1HMiTN
E+ftwWLR6AKpEtd5f3xKy2W8yT3c5B2me6Z91Jh0ZcaqhQLQsq+W3Ffy/zZKwNsN
aAm05TDjq/6VHmkjWGUUHM4mcHhS6daHIPKHiv6i2waPQ8Q+uHFAxgw7pn3xeG6Y
9UX/IobhuzaV1O+0LLe2YV8VIacdwjifmsc6NQBdvDaPU7KRko6bpH+eGQ7RBiMv
prqy7Ntv4em6ZwaUL+JIKbLjpPlyuDMCAwEAAaMvMC0wCQYDVR0TBAIwADALBgNV
HQ8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwIwDQYJKoZIhvcNAQEFBQADggEB
AK/E6ruFariPzR6CQseaNIMGgHt55lginPRhuPdEHVmVGJlYxJgj/aZkRxjdZzId
OEae+708RbQmHIBFeBUr1A3eg/o9Iu+czy8gHBm/n5BHroTbTExtmcFAxNr0yK5h
FPLDc0AShfz5WGyapnodOx2mE8INX1FXLugQPfknfv9GcCo92+RYoA4ZrX5PU8qC
tJ1UQZDFZU0g+C/EFz76q//BhA5XowYP14A9TPxiMmFIHSC0lIUB8H8e+SNU6Bs0
P19dHRJZv9sjkIm8+hxW+rvi1KFoDQzU4ycX9XDyWTO53GA+GUAHyUo77D0/MPeL
4K3b2y5wh9JUc+VSo1q1Brs=
-----END CERTIFICATE-----"

rabbitmq_ssl_private_key_test = "-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA1Igg2JNSGqV90gKB8lZLnNs0jYuhIMzr6F0xoPGUl24cUY+N
S4iJaSpOZNKhL+Zm2z3boSHYqOF5WIhSaeN9tQ7AQsYnEVx44QExUzTifXyUMb0+
3UcyJM0T5+3BYtHoAqkS13l/fErLZbzJPdzkHaZ7pn3UmHRlxqqFAtCyr5bcV/L/
NkrA2w1oCbTlMOOr/pUeaSNYZRQcziZweFLp1ocg8oeK/qLbBo9DxD64cUDGDDum
ffF4bpj1Rf8ihuG7NpXU77Qst7ZhXxUhpx3COJ+axzo1AF28No9TspGSjpukf54Z
DtEGIy+murLs22/h6bpnBpQv4kgpsuOk+XK4MwIDAQABAoIBABGfP+n1PSeMdURG
hPPNB/P3kQHzg+auVxkrMQRBQ6rSrHJuzq5moc4gfeOKO2c3WWvwUxenMMm/+EnI
89xnynKKyJJAz9h2rGcrrCVUCzuQatE8+ctrLdMzVeUzJ4fEE9K0piVLo7BwmzDS
WHVSrW9v8Gy7njcN36p7VRAIsegxGVa/+1lkZGFtynK6buXwgMCNGzlzk2QiwCzR
I7Z74rf6RbQYGffFmcKMKfJr+KiYeSMVJ1LLOUl9wL+s7EfMwU8FQmwrun+28NTZ
/4H8XV9YW4UjOepN1zuB8UxNJJd77IG6JXUlDE4HMt3dEjg1s6vDUISXGXNUs3JH
spUxSIECgYEA9HCVtffKaOvPG+7ZOS7KioYFHIrIXT34K+JTtuSM46eXB9aMYZCt
sda+DUeKYjL1YEF7h8KoNqn6bmQhdky00EgX5DHZ/mwyx9tmgzCiYk8wJeKENfSY
tGztD2s7LqL/w8iSdLhTOVBbwZd5e9INsy/csRnbGvm2PztVaLDLx1MCgYEA3pU8
Nazw8u/9MitmShgsmh5+TeEM1OmTZj9V81pROhsay6RUMsNv3AMo6OpJuK2ccNY7
V7z01KAzYrpnDMUynO09hOJ/Ude9/caico5rk17ZIehx0xEOu8gSKfq27OOTZfX0
aFokaOXiRNEQ7B+3vceTc2ikcfqnRH8iN4fhj6ECgYAVTu8uErC5Xr0KMVMMUhDj
7HTrnQmEX0+P+8XSbq/9dHGNBF3ub19E3nRo0fC1SL3tKygqmIRzZ3PmRaJJHryw
X2h9wv6+2A3BMFYKX6X4LfEDjHB8B5t8NvafXnilQx5KoeRqelr+5wton9y+N3xs
P2LcqWVZP6Vsc66pVqgc8wKBgQDCkSF4qhxVwINL/7QCwO78KfuuiDN3SlaW4nZ3
q1Olv1vE93jChySY5go0z9hxnxFJcXueToaV9xP0EY1TFG4RzzAfoP46xKRH2gLW
sLhIsniLs20MW7TNYS6/k3Gj0atfTYjAT0vUhl8sWLS6M1+ifXrfP3HAUKM2tQts
D1OVAQKBgCxcbeztUxD4b6V1a9xnC6SsiZirrVdZRFI8Xe1dUyL0jEPf5mH3eF0x
BpIpKUvLh4TsmgcezGV5512sm+K/TNNDynKY8vhVA8v9PNGiq6UJJkVRow5Ptes0
Pj3BM+E9hNMOQ6N7H87G4rbDz4T/kswNSiyF3v5Vlm0U5nGWWbk7
-----END RSA PRIVATE KEY-----"

describe 'sensu', :type => :class do
  let(:facts) do
    {
      :fqdn            => 'hostname.domain.com',
      :operatingsystem => 'CentOS',
      :osfamily        => 'RedHat',
      :kernel          => 'Linux',
    }
  end
  let(:params_base) { { :client => true } }
  let(:params_override) { {} }
  let(:params) { params_base.merge(params_override) }

  context 'rabbitmq config' do
    context 'no ssl (default)' do
      it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
        :ssl_cert_chain  => nil,
        :ssl_private_key => nil
      ) }

    end # no ssl (default)

    context 'when using local key' do
      let(:params) { {
        :rabbitmq_ssl_cert_chain  => '/etc/private/ssl/cert.pem',
        :rabbitmq_ssl_private_key => '/etc/private/ssl/key.pem',
        :rabbitmq_port            => '1234',
        :rabbitmq_host            => 'myhost',
        :rabbitmq_user            => 'sensuuser',
        :rabbitmq_password        => 'sensupass',
        :rabbitmq_vhost           => 'myvhost',
      } }

      it { should_not contain_file('/etc/sensu/ssl/cert.pem') }
      it { should_not contain_file('/etc/sensu/ssl/key.pem') }

      it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
        :port            => '1234',
        :host            => 'myhost',
        :user            => 'sensuuser',
        :password        => 'sensupass',
        :vhost           => 'myvhost',
        :ssl_cert_chain  => '/etc/private/ssl/cert.pem',
        :ssl_private_key => '/etc/private/ssl/key.pem'
      ) }
    end # when using local key

    context 'when using SSL transport' do
      let(:params) { {
        :rabbitmq_ssl => true,
      } }

      it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
        :ssl_transport  => true
      ) }
    end # when using SSL transport

    context 'when using key in puppet' do
      let(:params) { {
        :rabbitmq_ssl_cert_chain  => 'puppet:///modules/sensu/cert.pem',
        :rabbitmq_ssl_private_key => 'puppet:///modules/sensu/key.pem',
        :rabbitmq_port            => '1234',
        :rabbitmq_host            => 'myhost',
        :rabbitmq_user            => 'sensuuser',
        :rabbitmq_password        => 'sensupass',
        :rabbitmq_vhost           => '/myvhost',
      } }

      it { should contain_file('/etc/sensu/ssl').with_ensure('directory') }
      it { should contain_file('/etc/sensu/ssl/cert.pem').with_source('puppet:///modules/sensu/cert.pem') }
      it { should contain_file('/etc/sensu/ssl/key.pem').with_source('puppet:///modules/sensu/key.pem') }

      it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
        :port            => '1234',
        :host            => 'myhost',
        :user            => 'sensuuser',
        :password        => 'sensupass',
        :vhost           => '/myvhost',
        :ssl_cert_chain  => '/etc/sensu/ssl/cert.pem',
        :ssl_private_key => '/etc/sensu/ssl/key.pem'
      ) }
    end # when using key in puppet

    context 'when using key in variable' do
      let(:params) { {
        :rabbitmq_ssl_cert_chain  => rabbitmq_ssl_cert_chain_test,
        :rabbitmq_ssl_private_key => rabbitmq_ssl_private_key_test,
        :rabbitmq_port            => '1234',
        :rabbitmq_host            => 'myhost',
        :rabbitmq_user            => 'sensuuser',
        :rabbitmq_password        => 'sensupass',
        :rabbitmq_vhost           => '/myvhost',
      } }

      it { should contain_file('/etc/sensu/ssl').with_ensure('directory') }
      it { should contain_file('/etc/sensu/ssl/cert.pem').with_content(rabbitmq_ssl_cert_chain_test) }
      it { should contain_file('/etc/sensu/ssl/key.pem').with_content(rabbitmq_ssl_private_key_test) }

      it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
        :port            => '1234',
        :host            => 'myhost',
        :user            => 'sensuuser',
        :password        => 'sensupass',
        :vhost           => '/myvhost',
        :ssl_cert_chain  => '/etc/sensu/ssl/cert.pem',
        :ssl_private_key => '/etc/sensu/ssl/key.pem'
      ) }
    end # when using key in variable

    context 'when using rabbitmq cluster' do
      let(:cluster_config) {
        [
          {
            'port'            => '1234',
            'host'            => 'myhost',
            'user'            => 'sensuuser',
            'password'        => 'sensupass',
            'vhost'           => '/myvhost',
            'ssl_cert_chain'  => '/etc/sensu/ssl/cert.pem',
            'ssl_private_key' => '/etc/sensu/ssl/key.pem'
          },
          {
            'port'            => '1234',
            'host'            => 'myhost',
            'user'            => 'sensuuser',
            'password'        => 'sensupass',
            'vhost'           => '/myvhost',
            'ssl_cert_chain'  => '/etc/sensu/ssl/cert.pem',
            'ssl_private_key' => '/etc/sensu/ssl/key.pem'
          }
        ]
      }

      let(:params_base) { {
        :rabbitmq_ssl_cert_chain  => rabbitmq_ssl_cert_chain_test,
        :rabbitmq_ssl_private_key => rabbitmq_ssl_private_key_test,
        :rabbitmq_cluster => cluster_config
      } }

      it { should contain_file('/etc/sensu/ssl').with_ensure('directory') }
      it { should contain_file('/etc/sensu/ssl/cert.pem').with_content(rabbitmq_ssl_cert_chain_test) }
      it { should contain_file('/etc/sensu/ssl/key.pem').with_content(rabbitmq_ssl_private_key_test) }
      it { should contain_sensu_rabbitmq_config('hostname.domain.com').with_cluster(cluster_config) }

      context 'with rabbitmq_* class parameters also specified (#598)' do
        describe 'sensu::rabbitmq_port' do
          let(:params_override) { { rabbitmq_port: 6379 } }
          it { is_expected.to contain_sensu_rabbitmq_config(facts[:fqdn]).without_port }
        end

        describe 'sensu::rabbitmq_host' do
          let(:params_override) { { rabbitmq_host: 'rabbitmq.example.com' } }
          it { is_expected.to contain_sensu_rabbitmq_config(facts[:fqdn]).without_host }
        end

        describe 'sensu::rabbitmq_user' do
          let(:params_override) { { rabbitmq_user: 'sensu-ignored' } }
          it { is_expected.to contain_sensu_rabbitmq_config(facts[:fqdn]).without_user }
        end

        describe 'sensu::rabbitmq_password' do
          let(:params_override) { { rabbitmq_password: 'ignored-secret' } }
          it { is_expected.to contain_sensu_rabbitmq_config(facts[:fqdn]).without_password }
        end

        describe 'sensu::rabbitmq_vhost' do
          let(:params_override) { { rabbitmq_vhost: '/sensu-ignored' } }
          it { is_expected.to contain_sensu_rabbitmq_config(facts[:fqdn]).without_vhost }
        end

        describe 'sensu::rabbitmq_heartbeat' do
          let(:params_override) { { rabbitmq_heartbeat: 30 } }
          it { is_expected.to contain_sensu_rabbitmq_config(facts[:fqdn]).without_heartbeat }
        end

        describe 'sensu::rabbitmq_prefetch' do
          let(:params_override) { { rabbitmq_prefetch: 1 } }
          it { is_expected.to contain_sensu_rabbitmq_config(facts[:fqdn]).without_prefetch }
        end
      end
    end

    context 'when using prefetch attribute' do
      let(:params) { {
        :rabbitmq_host => 'myhost',
        :rabbitmq_prefetch => '10'
      } }

      it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
        :host => 'myhost',
        :prefetch  => '10'
      ) }
    end # when using prefetch attribute

    context 'when using heartbeat attribute' do
      let(:params) { {
        :rabbitmq_host => 'myhost',
        :rabbitmq_heartbeat => '10'
      } }

      it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
        :host => 'myhost',
        :heartbeat  => '10'
      ) }
    end # when using heartbeat attribute

    context 'purge config' do
      let(:params) { {
        :purge          => { 'config' => true },
        :server         => false,
        :client         => false,
        :enterprise     => false,
        :transport_type => 'redis'
      } }

      it { should contain_file('/etc/sensu/conf.d/rabbitmq.json').with_ensure('absent') }
    end
  end # rabbitmq config
end
