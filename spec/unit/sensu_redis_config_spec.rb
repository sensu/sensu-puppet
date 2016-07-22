require 'spec_helper'

describe Puppet::Type.type(:sensu_redis_config) do
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
        :catalog => Puppet::Resource::Catalog.new(),
    }
  end

  let :type_instance do
    create_type_instance(resource_hash)
  end

  describe 'reconnect_on_error property' do
    it 'defaults to false' do
      expect(type_instance[:reconnect_on_error]).to be :false
    end

    [true, :true, 'true', 'True', :yes, 'yes'].each do |v|
      it "accepts #{v.inspect} as true" do
        type_instance[:reconnect_on_error] = v
        expect(type_instance[:reconnect_on_error]).to be :true
      end
    end

    [false, :false, 'false', 'False', :no, 'no'].each do |v|
      it "accepts #{v.inspect} as false" do
        type_instance[:reconnect_on_error] = v
        expect(type_instance[:reconnect_on_error]).to be :false
      end
    end

    it 'rejects "foobar" as a value' do
      expect {
        type_instance[:reconnect_on_error] = 'foobar'
      }.to raise_error Puppet::Error, /expected a boolean value/
    end

  end

  describe "sentinels" do
    it "defaults (no sentinels)" do
      expect(type_instance.parameter(:sentinels).value).to eq([])
    end

    context "single value" do
      let :inst do
        create_type_instance(resource_hash.merge({
          :sentinels => {
            'host' => 'redis.sentinel.1',
            'port' => '12345',
          }
        }))
      end

      it "munges it (to array with port as int)" do
        expect(inst.parameter(:sentinels).value).to eq([{
          'host' => 'redis.sentinel.1',
          'port' => 12345
        }])
      end

      it "assumes insync? for the same values" do
        expect(inst.parameter(:sentinels).safe_insync?([
            'host' => 'redis.sentinel.1',
            'port' => 12345
        ])).to be true
      end

      [nil, []].each do |v|
        it "assumes not insync? for empty value #{v.inspect}" do
          expect(inst.parameter(:sentinels).safe_insync?([])).to be false
        end
      end

      it "assumes not insync? for different value" do
        expect(inst.parameter(:sentinels).safe_insync?([
            'host' => 'redis.sentinel.1.foo',
            'port' => 12345
        ])).to be false
      end
    end

    context "multiple values" do
      let :inst do
        create_type_instance(resource_hash.merge({
          :sentinels => [{
            'host' => 'redis.sentinel.1',
            'port' => '12345',
          }, {
            'host' => 'redis.sentinel.2',
            'port' => 6789,
          }]
        }))
      end

      it "can munge them" do
        expect(inst.parameter(:sentinels).value).to eq([{
          'host' => 'redis.sentinel.1',
          'port' => 12345
        }, {
          'host' => 'redis.sentinel.2',
          'port' => 6789,
        }])
      end

      it "assumes insync? for the same values" do
        expect(inst.parameter(:sentinels).safe_insync?([{
          'host' => 'redis.sentinel.1',
          'port' => 12345
        }, {
          'host' => 'redis.sentinel.2',
          'port' => 6789,
        }])).to be true
      end

      it "assumes insync? for the same values in different order" do
        expect(inst.parameter(:sentinels).safe_insync?([{
          'host' => 'redis.sentinel.2',
          'port' => 6789,
        }, {
          'host' => 'redis.sentinel.1',
          'port' => 12345
        }])).to be true
     end
    end
  end

end
