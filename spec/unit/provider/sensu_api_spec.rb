require 'spec_helper'
require 'puppet/provider/sensu_api'
require 'ostruct'

describe Puppet::Provider::SensuAPI do
  subject { Puppet::Provider::SensuAPI }

  describe 'version' do
    it 'returns version' do
      allow(described_class).to receive(:api_request).with('/version', nil, {:failonfail => false}).and_return({'sensu_backend' => '6.1.0'})
      expect(described_class.version).to eq('6.1.0')
    end
    it 'returns nil if no version' do
      allow(described_class).to receive(:api_request).with('/version', nil, {:failonfail => false}).and_return({})
      expect(described_class.version).to eq(nil)
    end
  end

  describe 'version_cmp' do
    it 'returns true' do
      described_class.instance_variable_set('@current_version', '6.1.0')
      expect(described_class.version_cmp('6.1.0')).to eq(true)
    end
    it 'returns true when malformed version' do
      described_class.instance_variable_set('@current_version', '(devel)')
      expect(described_class.version_cmp('6.1.0')).to eq(true)
    end
    it 'returns false' do
      described_class.instance_variable_set('@current_version', '6.0.0')
      expect(described_class.version_cmp('6.1.0')).to eq(false)
    end
  end
end
