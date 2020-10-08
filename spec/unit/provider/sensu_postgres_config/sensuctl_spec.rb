require 'spec_helper'

describe Puppet::Type.type(:sensu_postgres_config).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_postgres_config) }
  let(:resource) do
    type.new({
      :name => 'test',
      :dsn => 'postgresql://sensu:changeme@localhost:5432/sensu',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl).with(['dump','store/v1.PostgresConfig','--format','yaml','--all-namespaces']).and_return(my_fixture_read('dump.txt'))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a postres config' do
      allow(provider).to receive(:sensuctl).with(['dump','store/v1.PostgresConfig','--format','yaml','--all-namespaces']).and_return(my_fixture_read('dump.txt'))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('my-postgres')
    end
  end

  describe 'create' do
    it 'should create a postgres config' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :dsn => 'postgresql://sensu:changeme@localhost:5432/sensu',
        :pool_size => 0,
        :batch_buffer => 0,
        :batch_size => 1,
        :batch_workers => 0,
        :strict => false
      }
      allow(resource.provider).to receive(:version_cmp).and_return(true)
      expect(resource.provider).to receive(:sensuctl_create).with('PostgresConfig', expected_metadata, expected_spec, 'store/v1')
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(Puppet).not_to receive(:warning)
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a postgres config' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :dsn => 'postgresql://sensu:changeme@localhost:5432/sensu2',
        :pool_size => 0,
      }
      allow(resource.provider).to receive(:version_cmp).and_return(false)
      expect(resource.provider).to receive(:sensuctl_create).with('PostgresConfig', expected_metadata, expected_spec, 'store/v1')
      resource.provider.dsn = 'postgresql://sensu:changeme@localhost:5432/sensu2'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a postgres config' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :dsn => 'postgresql://sensu:changeme@localhost:5432/sensu',
        :pool_size => 0,
      }
      allow(resource.provider).to receive(:version_cmp).and_return(false)
      expect(resource.provider).to receive(:sensuctl_delete).with('PostgresConfig', 'test', nil, expected_metadata, expected_spec, 'store/v1')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

