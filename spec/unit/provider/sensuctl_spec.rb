require 'spec_helper'
require 'puppet/provider/sensuctl'
require 'ostruct'

describe Puppet::Provider::Sensuctl do
  subject { Puppet::Provider::Sensuctl }

  context 'config_path' do
    it 'should return path' do
      allow(Dir).to receive(:home).and_return('/root')
      expect(subject.config_path).to eq('/root/.config/sensu/sensuctl/cluster')
    end

    it 'should return path without Dir.home' do
      allow(Dir).to receive(:home).and_raise(NoMethodError)
      allow(Process).to receive(:uid).and_return(0)
      user = OpenStruct.new
      user.dir = '/root'
      allow(Etc).to receive(:getpwuid).with(0).and_return(user)
      expect(subject.config_path).to eq('/root/.config/sensu/sensuctl/cluster')
    end

    it 'should return path without HOME set' do
      allow(Dir).to receive(:home).and_raise(ArgumentError)
      allow(Process).to receive(:uid).and_return(0)
      user = OpenStruct.new
      user.dir = '/root'
      allow(Etc).to receive(:getpwuid).with(0).and_return(user)
      expect(subject.config_path).to eq('/root/.config/sensu/sensuctl/cluster')
    end
  end

  context 'sensuctl_list' do
    it 'should list a resource' do
      expected_args = ['check','list','--all-namespaces','--format','json']
      expect(subject).to receive(:sensuctl).with(expected_args, {failonfail: false}).and_return("{}\n")
      subject.sensuctl_list('check')
    end

    it 'should list a resource without all namespaces' do
      expected_args = ['namespace','list','--format','json']
      expect(subject).to receive(:sensuctl).with(expected_args, {failonfail: false}).and_return("{}\n")
      subject.sensuctl_list('namespace', false)
    end

    it 'should return empty array for null' do
      expected_args = ['check','list','--all-namespaces','--format','json']
      allow(subject).to receive(:sensuctl).with(expected_args, {failonfail: false}).and_return("null\n")
      data = subject.sensuctl_list('check')
      expect(data).to eq([])
    end

    it 'should execute with chunk-size' do
      subject.chunk_size = 100
      expected_args = ['check','list','--all-namespaces','--format','json','--chunk-size','100']
      expect(subject).to receive(:sensuctl).with(expected_args, {failonfail: false}).and_return("{}\n")
      subject.sensuctl_list('check')
    end
  end

  context 'sensuctl_create' do
    let(:tmp) { Tempfile.new() }
    before(:each) do
      allow(Tempfile).to receive(:new).with('sensuctl').and_return(tmp)
      allow(subject).to receive(:sensuctl).with(['create','--file',tmp.path])
    end

    it 'should have JSON with type' do
      subject.sensuctl_create('Test', {name: 'test'}, {foo: 'bar'})
      j = JSON.parse(File.read(tmp.path))
      expect(j['type']).to eq('Test')
    end

    it 'should have JSON with api_version' do
      subject.sensuctl_create('Test', {name: 'test'}, {foo: 'bar'})
      j = JSON.parse(File.read(tmp.path))
      expect(j['api_version']).to eq('core/v2')
    end

    it 'should have JSON with metadata' do
      subject.sensuctl_create('Test', {name: 'test'}, {foo: 'bar'})
      j = JSON.parse(File.read(tmp.path))
      expect(j['metadata']).to eq('name' => 'test')
    end

    it 'should have JSON with spec' do
      subject.sensuctl_create('Test', {name: 'test'}, {foo: 'bar'})
      j = JSON.parse(File.read(tmp.path))
      expect(j['spec']).to eq({'foo' => 'bar'})
    end

    it 'should have JSON with only valid keys' do
      subject.sensuctl_create('Test', {name: 'test'}, {foo: 'bar'})
      j = JSON.parse(File.read(tmp.path))
      expect(j.keys).to eq(['type','api_version','metadata','spec'])
    end

    it 'should create a resource' do
      expect(subject).to receive(:sensuctl).with(['create','--file',tmp.path])
      subject.sensuctl_create('Test', {name: 'test'}, {foo: 'bar'})
    end
  end

  context 'sensuctl_delete' do
    it 'should delete a resource' do
      expected_args = ['check','delete','test','--skip-confirm']
      expect(subject).to receive(:sensuctl).with(expected_args)
      subject.sensuctl_delete('check','test')
    end
  end

  context 'sensuctl_auth_types' do
    it 'should return auth and their types' do
      allow(subject).to receive(:sensuctl).with(['auth','list','--format','yaml']).and_return(my_fixture_read('auths.txt'))
      expect(subject.sensuctl_auth_types).to eq({"activedirectory"=>"AD", "activedirectory2"=>"AD", "openldap"=>"LDAP"})
    end
  end

  context 'dump' do
    it 'dumps multiple resources' do
      allow(subject).to receive(:sensuctl).with(['dump','federation/v1.EtcdReplicator','--format','yaml','--all-namespaces']).and_return(my_fixture_read('dump.txt'))
      ret = subject.dump('federation/v1.EtcdReplicator')
      expect(ret.size).to eq(2)
      expect(ret[0]['metadata']['name']).to eq('role_replicator')
    end
  end

  describe 'version' do
    it 'returns version' do
      allow(subject).to receive(:sensuctl).with(['version'], {:failonfail => false}).and_return('sensuctl version 6.1.0+ee, enterprise edition, build be1e65933de5be15a65066227f007ae369af1449, built 2020-10-02T01:15:38Z, built with go1.13.15')
      expect(subject.version).to eq('6.1.0')
    end
    it 'returns nil without version match' do
      allow(subject).to receive(:sensuctl).with(['version'], {:failonfail => false}).and_return('foobar')
      expect(subject.version).to eq(nil)
    end
  end

  describe 'version_cmp' do
    it 'returns true' do
      described_class.instance_variable_set('@current_version', '6.1.0')
      expect(subject.version_cmp('6.1.0')).to eq(true)
    end
    it 'returns true with malformed version' do
      described_class.instance_variable_set('@current_version', '(devel)')
      expect(subject.version_cmp('6.1.0')).to eq(true)
    end
    it 'returns false' do
      described_class.instance_variable_set('@current_version', '6.0.0')
      expect(subject.version_cmp('6.1.0')).to eq(false)
    end
  end
end
