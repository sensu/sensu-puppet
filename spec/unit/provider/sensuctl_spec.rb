require 'spec_helper'
require 'puppet/provider/sensuctl'
require 'ostruct'

describe Puppet::Provider::Sensuctl do
  subject { Puppet::Provider::Sensuctl }

  context 'config_path' do
    it 'should return path' do
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
      expect(subject).to receive(:sensuctl).with(expected_args).and_return("{}\n")
      subject.sensuctl_list('check')
    end

    it 'should list a resource without all namespaces' do
      expected_args = ['namespace','list','--format','json']
      expect(subject).to receive(:sensuctl).with(expected_args).and_return("{}\n")
      subject.sensuctl_list('namespace', false)
    end

    it 'should return empty array for null' do
      allow(subject).to receive(:sensuctl).with(['check','list','--all-namespaces','--format','json']).and_return("null\n")
      data = subject.sensuctl_list('check')
      expect(data).to eq([])
    end

    it 'should execute with chunk-size' do
      subject.chunk_size = 100
      expected_args = ['check','list','--all-namespaces','--format','json','--chunk-size','100']
      expect(subject).to receive(:sensuctl).with(expected_args).and_return("{}\n")
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

  context 'sensuctl_info' do
    it 'should get info for a resource' do
      expected_args = ['check','info','test','--format','json','--namespace','default']
      expect(subject).to receive(:sensuctl).with(expected_args).and_return("{}\n")
      subject.sensuctl_info('check', 'test', 'default')
    end
  end

  context 'sensuctl_auth_types' do
    it 'should return auth and their types' do
      allow(subject).to receive(:sensuctl).with(['auth','list','--format','yaml']).and_return(my_fixture_read('auths.txt'))
      expect(subject.sensuctl_auth_types).to eq({"activedirectory"=>"AD", "activedirectory2"=>"AD", "openldap"=>"LDAP"})
    end
  end
end
