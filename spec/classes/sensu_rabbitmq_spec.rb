require 'spec_helper'

describe 'sensu::rabbitmq', :type => :class do
  let(:title) { 'myrabbit' }
  let(:facts) { { :fqdn => 'hostname.domain.com' } }

  let(:params) { {
    :ssl_cert_chain   => '/etc/sensu/ssl/chain.pem',
    :ssl_private_key  => '/etc/sensu/ssl/key.pem',
    :port             => '1234',
    :host             => 'myhost',
    :user             => 'sensuuser',
    :password         => 'sensupass',
    :vhost            => '/myvhost'
  } }

  pending "it should test cert installs" do
#    if $ssl_cert_chain != '' {
#      file { '/etc/sensu/ssl':
#        ensure => directory,
#        owner  => 'sensu',
#        group  => 'sensu',
#        mode   => '0755',
#        require => Package['sensu'],
#      }
#
#      if $ssl_cert_chain =~ /^puppet:\/\// {
#        file { '/etc/sensu/ssl/cert.pem':
#          ensure  => present,
#          source  => $ssl_cert_chain,
#          owner   => 'sensu',
#          group   => 'sensu',
#          mode    => '0444',
#          require => File['/etc/sensu/ssl'],
#          before  => Sensu_rabbitmq_config[$::fqdn],
#        }
#
#        Sensu_rabbitmq_config {
#          ssl_cert_chain => '/etc/sensu/ssl/cert.pem',
#        }
#      } else {
#        Sensu_rabbitmq_config {
#          ssl_cert_chain => $ssl_cert_chain,
#        }
#      }
#
#      if $ssl_private_key =~ /^puppet:\/\// {
#        file { '/etc/sensu/ssl/key.pem':
#          ensure  => present,
#          source  => $ssl_private_key,
#          owner   => 'sensu',
#          group   => 'sensu',
#          mode    => '0440',
#          require => File['/etc/sensu/ssl'],
#          before  => Sensu_rabbitmq_config[$::fqdn],
#        }
#        Sensu_rabbitmq_config {
#          ssl_private_key => '/etc/sensu/ssl/key.pem',
#        }
#      } else {
#        Sensu_rabbitmq_config {
#          ssl_private_key => $ssl_private_key,
#        }
#      }
  end

  it { should contain_sensu_rabbitmq_config('hostname.domain.com').with(
    'port'      => '1234',
    'host'      => 'myhost',
    'user'      => 'sensuuser',
    'password'  => 'sensupass',
    'vhost'     => '/myvhost'
  ) }

end





