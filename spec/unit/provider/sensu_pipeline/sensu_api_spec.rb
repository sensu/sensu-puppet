require 'spec_helper'

describe Puppet::Type.type(:sensu_pipeline).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_pipeline) }
  let(:resource) do
    type.new({
      :name => 'test',
      :workflows => [
        {
          'name'    => 'notify',
          'handler' => { 'name' => 'slack', 'type' => 'Handler', 'api_version' => 'core/v2' },
        },
      ],
      :provider => 'sensu_api',
    })
  end

  before(:each) do
    allow(provider).to receive(:namespaces).and_return(['default'])
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('pipelines', nil, {namespace: 'default'}).and_return(JSON.parse(my_fixture_read('pipeline_list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a pipeline' do
      allow(provider).to receive(:api_request).with('pipelines', nil, {namespace: 'default'}).and_return(JSON.parse(my_fixture_read('pipeline_list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('test in default')
    end
  end

  describe 'create' do
    it 'should create a pipeline' do
      expected_spec = {
        :workflows => [
          {
            'name'    => 'notify',
            'handler' => { 'name' => 'slack', 'type' => 'Handler', 'api_version' => 'core/v2' },
          },
        ],
        :continue_on_error => false,
        :metadata => {
          :name      => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('pipelines', expected_spec, {namespace: 'default', method: 'post'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a pipeline workflows' do
      expected_spec = {
        :workflows => [
          {
            'name'    => 'notify',
            'handler' => { 'name' => 'pagerduty', 'type' => 'Handler', 'api_version' => 'core/v2' },
          },
        ],
        :continue_on_error => false,
        :metadata => {
          :name      => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('pipelines/test', expected_spec, {namespace: 'default', method: 'put'})
      resource.provider.workflows = [
        {
          'name'    => 'notify',
          'handler' => { 'name' => 'pagerduty', 'type' => 'Handler', 'api_version' => 'core/v2' },
        },
      ]
      resource.provider.flush
    end
    it 'should update continue_on_error' do
      expected_spec = {
        :workflows => [
          {
            'name'    => 'notify',
            'handler' => { 'name' => 'slack', 'type' => 'Handler', 'api_version' => 'core/v2' },
          },
        ],
        :continue_on_error => true,
        :metadata => {
          :name      => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('pipelines/test', expected_spec, {namespace: 'default', method: 'put'})
      resource.provider.continue_on_error = :true
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a pipeline' do
      expect(resource.provider).to receive(:api_request).with('pipelines/test', nil, {namespace: 'default', method: 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end
