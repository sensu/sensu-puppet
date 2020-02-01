require 'spec_helper'

describe Puppet::Type.type(:sensuctl_configure).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensuctl_configure) }
  let(:resource) do
    type.new({
      :name => 'puppet',
      :username => 'admin',
      :password => 'foobar',
      :url => 'http://localhost:8080',
    })
  end

  describe 'config_format' do
    it 'should have value' do
      allow(resource.provider).to receive(:sensuctl).with(['config','view','--format','json']).and_return(my_fixture_read('config_list.json'))
      expect(resource.provider.config_format).to eq('tabular')
    end
  end
  describe 'config_namespace' do
    it 'should have value' do
      allow(resource.provider).to receive(:sensuctl).with(['config','view','--format','json']).and_return(my_fixture_read('config_list.json'))
      expect(resource.provider.config_namespace).to eq('default')
    end
  end

  describe 'backend_init' do
    before(:each) do
      resource[:old_password] = 'barbaz'
    end

    let(:custom_environment) do
      {
        'SENSU_BACKEND_CLUSTER_ADMIN_USERNAME' => resource[:username],
        'SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD' => resource[:password],
      }
    end

    it 'should execute sensu-backend init' do
      allow(resource.provider).to receive(:which).with('sensu-backend').and_return('/usr/sbin/sensu-backend')
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).with(resource[:url], resource[:username], 'foobar').and_return(false)
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).with(resource[:url], resource[:username], 'barbaz').and_return(false)
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).with(resource[:url], resource[:username], 'P@ssw0rd!').and_return(false)
      expect(resource.provider).to receive(:execute).with(['/usr/sbin/sensu-backend','init'],{failonfail: false, custom_environment: custom_environment})
      resource.provider.backend_init
    end

    it 'should skip if not sensu-backend' do
      allow(resource.provider).to receive(:which).with('sensu-backend').and_return(nil)
      expect(resource.provider).not_to receive(:execute)
      resource.provider.backend_init
    end

    it 'should skip if password matches' do
      allow(resource.provider).to receive(:which).with('sensu-backend').and_return('/usr/sbin/sensu-backend')
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).with(resource[:url], resource[:username], 'foobar').and_return(true)
      expect(resource.provider).not_to receive(:execute)
      resource.provider.backend_init
    end

    it 'should skip if old_password matches' do
      allow(resource.provider).to receive(:which).with('sensu-backend').and_return('/usr/sbin/sensu-backend')
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).with(resource[:url], resource[:username], 'foobar').and_return(false)
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).with(resource[:url], resource[:username], 'barbaz').and_return(true)
      expect(resource.provider).not_to receive(:execute)
      resource.provider.backend_init
    end

    it 'should skip if bootstrap_password matches' do
      allow(resource.provider).to receive(:which).with('sensu-backend').and_return('/usr/sbin/sensu-backend')
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).with(resource[:url], resource[:username], 'foobar').and_return(false)
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).with(resource[:url], resource[:username], 'barbaz').and_return(false)
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).with(resource[:url], resource[:username], 'P@ssw0rd!').and_return(true)
      expect(resource.provider).not_to receive(:execute)
      resource.provider.backend_init
    end
  end

  describe 'create' do
    before(:each) do
      allow(resource.provider).to receive(:exists?).and_return(false)
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).and_return(true)
    end

    it 'should run sensuctl configure' do
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','P@ssw0rd!'])
      resource.provider.create
    end
    it 'should run sensuctl configure without SSL' do
      resource[:trusted_ca_file] = 'absent'
      expect(resource.provider).to receive(:sensuctl).with(['configure','--non-interactive','--url','http://localhost:8080','--username','admin','--password','P@ssw0rd!'])
      resource.provider.create
    end
    it 'should run sensuctl configure with password' do
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).and_return(false)
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      resource.provider.create
    end
    it 'should run sensuctl configure with namespace' do
      resource[:config_namespace] = 'qa'
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).and_return(false)
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      expect(resource.provider).to receive(:sensuctl).with(['config','set-namespace','qa'])
      resource.provider.create
    end
  end

  describe 'flush' do
    before(:each) do
      allow(resource.provider).to receive(:exists?).and_return(true)
    end

    it 'should update a configure' do
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      resource.provider.url = 'https://localhost:8080'
      resource.provider.flush
    end
    it 'should remove SSL trusted ca' do
      expect(resource.provider).to receive(:sensuctl).with(['configure','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      resource.provider.trusted_ca_file = 'absent'
      resource.provider.flush
    end
    it 'should use old_password' do
      resource[:old_password] = 'foo'
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).and_return(true)
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foo'])
      resource.provider.url = 'https://localhost:8080'
      resource.provider.flush
    end
    it 'should use update namespace' do
      allow(Puppet::Provider::SensuAPI).to receive(:auth_test).and_return(true)
      expect(resource.provider).to receive(:sensuctl).with(['configure','--trusted-ca-file','/etc/sensu/ssl/ca.crt','--non-interactive','--url','http://localhost:8080','--username','admin','--password','foobar'])
      expect(resource.provider).to receive(:sensuctl).with(['config','set-namespace','qa'])
      resource.provider.config_namespace = 'qa'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should not support deleting a configure' do
      allow(resource.provider).to receive(:config_path).and_return('/root/.config/sensu/sensuctl/cluster')
      expect(File).to receive(:delete).with('/root/.config/sensu/sensuctl/cluster')
      resource.provider.destroy
    end
  end
end

