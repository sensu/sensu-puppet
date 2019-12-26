require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_tessen).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_tessen using sensu API"

  def state
    data = api_request('tessen')
    opt_out = data['opt_out'].nil? ? false : data['opt_out']
    if opt_out
      :absent
    else
      :present
    end
  end

  def create
    data = { "opt_out" => false }
    opts = {
      :method => 'put',
    }
    api_request('tessen', data, opts)
    @property_hash[:ensure] = :present
  end

  def destroy
    data = { "opt_out" => true }
    opts = {
      :method => 'put',
    }
    api_request('tessen', data, opts)
    @property_hash.clear
  end
end

