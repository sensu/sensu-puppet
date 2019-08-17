require 'spec_helper'

RSpec.shared_examples 'namespace' do
  it 'shoudl not fail if namespace defined' do
    config[:namespace] = 'devs'
    namespace = Puppet::Type.type(:sensu_namespace).new(:name => 'devs')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource res
    catalog.add_resource namespace
    expect { res.pre_run_check }.not_to raise_error
  end

  it 'should fail if namespace not defined' do
    config[:namespace] = 'dne'
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource res
    expect { res.pre_run_check }.to raise_error(Puppet::Error, /Sensu namespace 'dne' must be defined/)
  end
end
