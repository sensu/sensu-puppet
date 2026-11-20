require 'spec_helper'
require 'puppet/type/sensu_pipeline'

describe Puppet::Type.type(:sensu_pipeline) do
  let(:default_config) do
    {
      name: 'test',
      workflows: [
        {
          'name'    => 'notify',
          'handler' => { 'name' => 'slack', 'type' => 'Handler', 'api_version' => 'core/v2' },
        },
      ],
    }
  end
  let(:config) { default_config }
  let(:pipeline) { described_class.new(config) }

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect { catalog.add_resource pipeline }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  include_examples 'name_regex' do
    let(:default_params) { default_config }
  end

  it 'should handle composite title' do
    config.delete(:namespace)
    config[:name] = 'test in dev'
    expect(pipeline[:name]).to eq('test in dev')
    expect(pipeline[:resource_name]).to eq('test')
    expect(pipeline[:namespace]).to eq('dev')
  end

  it 'should handle non-composite title' do
    config[:name] = 'test'
    expect(pipeline[:name]).to eq('test')
    expect(pipeline[:resource_name]).to eq('test')
    expect(pipeline[:namespace]).to eq('default')
  end

  it 'should have a default namespace' do
    expect(pipeline[:namespace]).to eq('default')
  end

  it 'should default continue_on_error to false' do
    expect(pipeline[:continue_on_error]).to eq(:false)
  end

  describe 'workflows' do
    it 'should require workflows' do
      config.delete(:workflows)
      config[:ensure] = :present
      expect { pipeline.pre_run_check }.to raise_error(Puppet::Error, /workflows/)
    end

    it 'should accept a minimal workflow (name + handler only)' do
      config[:workflows] = [
        {
          'name'    => 'notify',
          'handler' => { 'name' => 'slack', 'type' => 'Handler', 'api_version' => 'core/v2' },
        },
      ]
      expect { pipeline }.to_not raise_error
    end

    it 'should accept a full workflow with filters and mutator' do
      config[:workflows] = [
        {
          'name'    => 'notify',
          'filters' => [{ 'name' => 'is_incident', 'type' => 'EventFilter', 'api_version' => 'core/v2' }],
          'mutator' => { 'name' => 'only_output', 'type' => 'Mutator', 'api_version' => 'core/v2' },
          'handler' => { 'name' => 'slack', 'type' => 'Handler', 'api_version' => 'core/v2' },
        },
      ]
      expect { pipeline }.to_not raise_error
    end

    it 'should require workflows elements to be Hashes' do
      config[:workflows] = ['not_a_hash']
      expect { pipeline }.to raise_error(Puppet::Error, /must be a Hash/)
    end

    it 'should require a name key in each workflow' do
      config[:workflows] = [{ 'handler' => { 'name' => 'slack', 'type' => 'Handler', 'api_version' => 'core/v2' } }]
      expect { pipeline }.to raise_error(Puppet::Error, /must have a 'name' key/)
    end

    it 'should require a handler key in each workflow' do
      config[:workflows] = [{ 'name' => 'notify' }]
      expect { pipeline }.to raise_error(Puppet::Error, /must have a 'handler' key/)
    end

    it 'should require handler to be a Hash with name, type, api_version' do
      config[:workflows] = [{ 'name' => 'notify', 'handler' => { 'name' => 'slack' } }]
      expect { pipeline }.to raise_error(Puppet::Error, /must have a 'type' key/)
    end

    it 'should reject invalid workflow keys' do
      config[:workflows] = [
        {
          'name'    => 'notify',
          'handler' => { 'name' => 'slack', 'type' => 'Handler', 'api_version' => 'core/v2' },
          'invalid' => 'key',
        },
      ]
      expect { pipeline }.to raise_error(Puppet::Error, /invalid is not a valid key/)
    end
  end

  describe 'continue_on_error' do
    it 'should accept true' do
      config[:continue_on_error] = true
      expect(pipeline[:continue_on_error]).to eq(:true)
    end

    it 'should accept false' do
      config[:continue_on_error] = false
      expect(pipeline[:continue_on_error]).to eq(:false)
    end
  end

  include_examples 'labels' do
    let(:res) { pipeline }
  end

  include_examples 'annotations' do
    let(:res) { pipeline }
  end
end
