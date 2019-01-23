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
    it 'defaults to true' do
      expect(type_instance[:reconnect_on_error]).to be :true
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

  describe "tls" do
    context "with defaults (no tls)" do
      it { expect(type_instance.parameter(:tls).value).to eq(:false) }
    end

    [true, 'true'].each do |v|
      context "should set tls to #{v}" do
        let :inst do
          create_type_instance(resource_hash.merge({:tls => v}))
        end

        it { expect(inst.parameter(:tls).value).to eq(:true) }
      end
    end

    [false, 'false'].each do |v|
      context "should set tls to #{v}" do
        let :inst do
          create_type_instance(resource_hash.merge({:tls => v}))
        end

        it { expect(inst.parameter(:tls).value).to eq(:false) }
      end
    end

    context 'invalid value' do
      let :inst do
        create_type_instance(resource_hash.merge({:tls => 'foo'}))
      end

      it 'should raise an error' do
        expect { inst }.to raise_error(Puppet::ResourceError, /Invalid value "foo". Valid values are true, false/)
      end
    end
  end

  describe "sentinels" do
    context "with defaults (no sentinels)" do
      it "no sentinels" do
        expect(type_instance.parameter(:sentinels).value).to eq([])
      end

      it "master.should is :absent" do
        expect(type_instance.parameter(:master).should).to eq(:absent)
      end

      it "assumes insync? for :absent value" do
        expect(type_instance.parameter(:master).safe_insync?(:absent)).to be true
      end

      ["abc", "absent"].each do |v|
        it "assumes not insync? for specified master value '#{v.inspect}'" do
          expect(type_instance.parameter(:master).safe_insync?(v)).to be false
        end
      end
    end

    context "with single sentinel" do
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

    context "with multiple sentinels" do
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

    context "when master is specified" do
      let :inst do
        create_type_instance(resource_hash.merge({
          :master => "master-name"
        }))
      end

      it "master name is propagated" do
        expect(inst.parameter(:master).value).to eq("master-name")
      end

      it "assumes insync? for the same master value" do
        expect(inst.parameter(:master).safe_insync?("master-name")).to be true
      end

      [:absent, "", nil].each do |v|
        it "assumes not insync? for empty master value #{v.inspect}" do
          expect(inst.parameter(:master).safe_insync?(v)).to be false
        end
      end

      it "assumes not insync? for different master value" do
        expect(inst.parameter(:master).safe_insync?("abc")).to be false
      end
    end
  end

  describe 'notifications' do
    context 'when managing sensu-enterprise (#495)' do
      let(:service_resource) do
        Puppet::Type.type(:service).new(name: 'sensu-enterprise')
      end
      let(:resource_hash) do
        c = Puppet::Resource::Catalog.new
        c.add_resource(service_resource)
        {
          :title => 'foo.example.com',
          :catalog => c
        }
      end

      it 'notifies Service[sensu-enterprise]' do
        notify_list = described_class.new(resource_hash)[:notify]
        # compare the resource reference strings, the object identities differ.
        expect(notify_list.map(&:ref)).to eq [service_resource.ref]
      end
    end
  end
end
