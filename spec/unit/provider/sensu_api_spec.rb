require 'spec_helper'
require 'puppet/provider/sensu_api'
require 'ostruct'

describe Puppet::Provider::SensuAPI do
  subject { Puppet::Provider::SensuAPI }

  describe 'version_cmp' do
    it 'returns true' do
      allow(described_class).to receive(:api_request).with('/version').and_return('6.1.0')
      expect(described_class.version_cmp('6.1.0')).to eq(true)
    end
    it 'returns false' do
      allow(described_class).to receive(:api_request).with('/version').and_return('6.0.0')
      expect(described_class.version_cmp('6.1.0')).to eq(true)
    end
  end
end
