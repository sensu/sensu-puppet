require 'spec_helper'

RSpec.shared_examples 'namespace' do
  it 'should not fail if namespace defined' do
    config[:namespace] = 'default'
    namespace = Puppet::Type.type(:sensu_namespace).new(:name => 'default')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource res
    catalog.add_resource namespace
    expect { res.pre_run_check }.not_to raise_error
  end

  it 'should not fail if namespace exists' do
    allow(res.provider).to receive(:validate_namespaces).and_return(true)
    allow(res.provider).to receive(:namespaces).and_return(['devs','default'])
    config[:namespace] = 'devs'
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource res
    expect { res.pre_run_check }.not_to raise_error
  end

  it 'should fail if namespace not defined' do
    config[:namespace] = 'dne'
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource res
    expect { res.pre_run_check }.to raise_error(Puppet::Error, /Sensu namespace 'dne' must be defined/)
  end
end
