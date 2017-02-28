require 'spec_helper'

describe Puppet::Type.type(:sensu_enterprise_dashboard_api_config) do
  provider_class = described_class.provider(:json)

  let :resource_hash do
    {
      :title   => 'foo.example.com',
      :catalog => Puppet::Resource::Catalog.new()
    }
  end

  let :type_instance do
    result            = described_class.new(resource_hash)
    provider_instance = provider_class.new(resource_hash)
    result.provider   = provider_instance
    result
  end

  describe "defaults ensure to 'present'" do
    it do
      expect(type_instance[:ensure]).to eq(:present)
    end
  end

  context 'accepts String values for :ensure' do
    describe "accepts value 'present' for :ensure" do
      it do
        type_instance[:ensure] = 'present'
        expect(type_instance[:ensure]).to eq(:present)
      end
      describe "accepts String value 'absent' for :ensure" do
        it do
          type_instance[:ensure] = 'absent'
          expect(type_instance[:ensure]).to eq(:absent)
        end
      end
    end
  end
end
