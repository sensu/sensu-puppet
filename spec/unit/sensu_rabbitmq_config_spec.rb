require 'spec_helper'

describe Puppet::Type.type(:sensu_rabbitmq_config) do
  let :provider_class do
    described_class.provider(:json)
  end

  def create_type_instance(resource_hash)
    result = described_class.new(resource_hash)
    provider_instance = provider_class.new(resource_hash)
    result.provider = provider_instance
    result
  end

  let :resource_hash do 
    {
      :title   => 'foo.example.com',
      :catalog => Puppet::Resource::Catalog.new()
    } 
  end

  let :cluster_proper do
    {
      :cluster => [{
        'port'            => '1234',
        'host'            => 'myhost',
        'user'            => 'sensuuser',
        'password'        => 'sensupass',
        'vhost'           => '/myvhost',
        'ssl_cert_chain'  => '/etc/sensu/ssl/cert.pem',
        'ssl_private_key' => '/etc/sensu/ssl/key.pem'
      }]
    }
  end

  let :wout_port do
    {
      :cluster => [{
        'port' => :undef,
        'host'            => 'myhost',
        'user'            => 'sensuuser',
        'password'        => 'sensupass',
        'vhost'           => '/myvhost',
        'ssl_cert_chain'  => '/etc/sensu/ssl/cert.pem',
        'ssl_private_key' => '/etc/sensu/ssl/key.pem'
      }]
    }
  end

  let :cluster_arrays do
    {
      :cluster => [
        ['port'            , '1234'],
        ['host'            , 'myhost'],
        ['user'            , 'sensuuser'],
        ['password'        , 'sensupass'],
        ['vhost'           , '/myvhost'],
        ['ssl_cert_chain'  , '/etc/sensu/ssl/cert.pem'],
        ['ssl_private_key' , '/etc/sensu/ssl/key.pem']
      ]
    }
  end

  describe 'cluster' do
    context 'when cluster is defined' do
      context 'as an array of hashes' do
        let(:subject) { create_type_instance(resource_hash.merge(cluster_proper)) }

        it 'should be an array of hashes' do
          cluster_val = subject.parameter(:cluster).value
          expect(cluster_val).to be_an(Array)
          expect(cluster_val).to eq([{
            'port'            => 1234,
            'host'            => 'myhost',
            'user'            => 'sensuuser',
            'password'        => 'sensupass',
            'vhost'           => '/myvhost',
            'ssl_cert_chain'  => '/etc/sensu/ssl/cert.pem',
            'ssl_private_key' => '/etc/sensu/ssl/key.pem'
          }])
        end
      end

      context 'as an array of arrays' do
        let(:subject) { create_type_instance(resource_hash.merge(cluster_arrays)) }

        it 'should raise an error' do
          expect {subject}.to raise_error(Puppet::ResourceError)
        end
      end

      context 'and port is undef' do
        let(:subject) { create_type_instance(resource_hash.merge(wout_port))}

        it 'should not raise an error' do
          expect { subject }.to_not raise_error
        end
      end
    end
  end
end
