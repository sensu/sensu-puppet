require 'spec_helper'
require 'puppet/type/sensu_check'

describe Puppet::Type.type(:sensu_check) do
  before(:each) do
    @sensu_check = described_class.new(
      name: 'test',
      command: 'test',
      subscriptions: ['test'],
      handlers: ['test']
    )
  end

  it 'should add to catalog with raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource @sensu_check
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not accept invalid name' do
    expect {
      @sensu_check[:name] = 'foo bar'
    }.to raise_error(Puppet::Error)
  end

  it 'should accept command' do
    @sensu_check[:command] = '/foo/bar'
    expect(@sensu_check[:command]).to eq('/foo/bar')
  end

  it 'should accept subscriptions' do
    @sensu_check[:subscriptions] = ['foo', 'bar']
    expect(@sensu_check[:subscriptions]).to eq(['foo', 'bar'])
  end

  it 'should accept handlers' do
    @sensu_check[:handlers] = ['foo', 'bar']
    expect(@sensu_check[:handlers]).to eq(['foo', 'bar'])
  end

  it 'should accept interval' do
    @sensu_check[:interval] = 5
    expect(@sensu_check[:interval]).to eq(5)
  end

  it 'should accept interval string' do
    @sensu_check[:interval] = '5'
    expect(@sensu_check[:interval]).to eq(5)
  end

  it 'should not accept invalid interval' do
    expect {
      @sensu_check[:interval] = 'foobar'
    }.to raise_error(Puppet::ResourceError, /not a valid integer/)
  end

  it 'should accept cron' do
    @sensu_check[:cron] = '0 0 * * *'
    expect(@sensu_check[:cron]).to eq('0 0 * * *')
  end

  it 'should accept publish' do
    @sensu_check[:publish] = true
    expect(@sensu_check[:publish]).to eq(:true)
    @sensu_check[:publish] = 'true'
    expect(@sensu_check[:publish]).to eq(:true)
  end

  it 'should not accept invalid publish' do
    expect {
      @sensu_check[:publish] = 'foobar'
    }.to raise_error(Puppet::ResourceError)
  end

  it 'should accept timeout' do
    @sensu_check[:timeout] = 5
    expect(@sensu_check[:timeout]).to eq(5)
  end

  it 'should accept timeout string' do
    @sensu_check[:timeout] = '5'
    expect(@sensu_check[:timeout]).to eq(5)
  end

  it 'should not accept invalid timeout' do
    expect {
      @sensu_check[:timeout] = 'foobar'
    }.to raise_error(Puppet::ResourceError, /not a valid integer/)
  end

  it 'should accept ttl' do
    @sensu_check[:ttl] = 5
    expect(@sensu_check[:ttl]).to eq(5)
  end

  it 'should accept ttl string' do
    @sensu_check[:ttl] = '5'
    expect(@sensu_check[:ttl]).to eq(5)
  end

  it 'should not accept invalid ttl' do
    expect {
      @sensu_check[:ttl] = 'foobar'
    }.to raise_error(Puppet::ResourceError, /not a valid integer/)
  end

  it 'should accept stdin' do
    @sensu_check[:stdin] = true
    expect(@sensu_check[:stdin]).to eq(:true)
    @sensu_check[:stdin] = 'true'
    expect(@sensu_check[:stdin]).to eq(:true)
  end

  it 'should not accept invalid stdin' do
    expect {
      @sensu_check[:stdin] = 'foobar'
    }.to raise_error(Puppet::ResourceError)
  end

  it 'should accept low_flap_threshold' do
    @sensu_check[:low_flap_threshold] = 5
    expect(@sensu_check[:low_flap_threshold]).to eq(5)
  end

  it 'should accept low_flap_threshold string' do
    @sensu_check[:low_flap_threshold] = '5'
    expect(@sensu_check[:low_flap_threshold]).to eq(5)
  end

  it 'should not accept invalid low_flap_threshold' do
    expect {
      @sensu_check[:low_flap_threshold] = 'foobar'
    }.to raise_error(Puppet::ResourceError, /not a valid integer/)
  end

  it 'should accept high_flap_threshold' do
    @sensu_check[:high_flap_threshold] = 5
    expect(@sensu_check[:high_flap_threshold]).to eq(5)
  end

  it 'should accept high_flap_threshold string' do
    @sensu_check[:high_flap_threshold] = '5'
    expect(@sensu_check[:high_flap_threshold]).to eq(5)
  end

  it 'should not accept invalid high_flap_threshold' do
    expect {
      @sensu_check[:high_flap_threshold] = 'foobar'
    }.to raise_error(Puppet::ResourceError, /not a valid integer/)
  end

  it 'should accept runtime_assets' do
    @sensu_check[:runtime_assets] = ['foo', 'bar']
    expect(@sensu_check[:runtime_assets]).to eq(['foo', 'bar'])
  end

  it 'should accept check_hooks' do
    @sensu_check[:check_hooks] = ['foo', 'bar']
    expect(@sensu_check[:check_hooks]).to eq(['foo', 'bar'])
  end

  it 'should accept subdue' do
    skip("Not sure what subdue looks like")
  end

  it 'should accept proxy_entity_id' do
    @sensu_check[:proxy_entity_id] = 'foobar'
    expect(@sensu_check[:proxy_entity_id]).to eq('foobar')
  end

  it 'should not accept invalid proxy_entity_id' do
    expect {
      @sensu_check[:proxy_entity_id] = 'foo bar'
    }.to raise_error(Puppet::ResourceError)
  end

  it 'should accept proxy_requests' do
    @sensu_check[:proxy_requests] = 'present'
    expect(@sensu_check[:proxy_requests]).to eq(:present)
    @sensu_check[:proxy_requests] = 'absent'
    expect(@sensu_check[:proxy_requests]).to eq(:absent)
  end

  it 'should not accept invalid proxy_requests' do
    expect {
      @sensu_check[:proxy_requests] = 'foo'
    }.to raise_error(Puppet::ResourceError)
  end

=begin
  it 'should accept proxy_requests' do
    @sensu_check[:proxy_requests] = {
      "entity_attributes": ["entity.Class == 'proxy'"],
      "splay": true,
      "splay_coverage": 65
    }
    expect(@sensu_check[:proxy_requests]).to include("entity_attributes": ["entity.Class == 'proxy'"])
    expect(@sensu_check[:proxy_requests]).to include("splay": true)
    expect(@sensu_check[:proxy_requests]).to include("splay_coverage": 65)
  end

  it 'should not accept non-hash for proxy_requests' do
    expect {
      @sensu_check[:proxy_requests] = 'foobar'
    }.to raise_error(Puppet::ResourceError)
  end

  it 'should not accept invalid keys for proxy_requests' do
    expect {
      @sensu_check[:proxy_requests] = {'foo': 'bar'}
    }.to raise_error(Puppet::ResourceError)
  end
=end

  it 'should accept round_robin' do
    @sensu_check[:round_robin] = true
    expect(@sensu_check[:round_robin]).to eq(:true)
    @sensu_check[:round_robin] = 'true'
    expect(@sensu_check[:round_robin]).to eq(:true)
  end

  it 'should not accept invalid round_robin' do
    expect {
      @sensu_check[:round_robin] = 'foobar'
    }.to raise_error(Puppet::ResourceError)
  end

  it 'should accept organization' do
    @sensu_check[:organization] = 'default'
    expect(@sensu_check[:organization]).to eq('default')
  end

  it 'should accept environment' do
    @sensu_check[:environment] = 'default'
    expect(@sensu_check[:environment]).to eq('default')
  end

  it 'should accept proxy_requests_entity_attributes' do
    @sensu_check[:proxy_requests_entity_attributes] = ['foo', 'bar']
    expect(@sensu_check[:proxy_requests_entity_attributes]).to eq(['foo', 'bar'])
  end

  it 'should accept proxy_requests_splay' do
    @sensu_check[:proxy_requests_splay] = true
    expect(@sensu_check[:proxy_requests_splay]).to eq(:true)
    @sensu_check[:proxy_requests_splay] = 'true'
    expect(@sensu_check[:proxy_requests_splay]).to eq(:true)
  end

  it 'should not accept invalid proxy_requests_splay' do
    expect {
      @sensu_check[:proxy_requests_splay] = 'foobar'
    }.to raise_error(Puppet::ResourceError)
  end

  it 'should accept proxy_requests_splay_coverage' do
    @sensu_check[:proxy_requests_splay_coverage] = 5
    expect(@sensu_check[:proxy_requests_splay_coverage]).to eq(5)
  end

  it 'should accept proxy_requests_splay_coverage string' do
    @sensu_check[:proxy_requests_splay_coverage] = '5'
    expect(@sensu_check[:proxy_requests_splay_coverage]).to eq(5)
  end

  it 'should not accept invalid proxy_requests_splay_coverage' do
    expect {
      @sensu_check[:proxy_requests_splay_coverage] = 'foobar'
    }.to raise_error(Puppet::ResourceError, /not a valid integer/)
  end

  it 'should autorequire Package[sensu-cli]' do
    package = Puppet::Type.type(:package).new(:name => 'sensu-cli')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @sensu_check
    catalog.add_resource package
    rel = @sensu_check.autorequire[0]
    expect(rel.source.ref).to eq(package.ref)
    expect(rel.target.ref).to eq(@sensu_check.ref)
  end

  it 'should autorequire Service[sensu-backend]' do
    service = Puppet::Type.type(:service).new(:name => 'sensu-backend')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @sensu_check
    catalog.add_resource service
    rel = @sensu_check.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(@sensu_check.ref)
  end

  it 'should autorequire sensu_api_validator' do
    validator = Puppet::Type.type(:sensu_api_validator).new(:name => 'sensu')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @sensu_check
    catalog.add_resource validator
    rel = @sensu_check.autorequire[0]
    expect(rel.source.ref).to eq(validator.ref)
    expect(rel.target.ref).to eq(@sensu_check.ref)
  end
end
