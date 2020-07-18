require 'spec_helper'
require_relative '../../tasks/backend_upgrade.rb'

describe SensuBackendUpgrade do
  let(:output) { my_fixture_read('logs.out') }
  let(:logs) do
    [
      {"component" => "store","level" => "warning","msg" => "migrating etcd database to a new version","time" => "2020-07-11T15:07:50Z"},
      {"component" => "store","database_version" => 1,"level" => "info","msg" => "successfully upgraded database","time" => "2020-07-11T15:07:50Z"},
      {"component" => "store","database_version" => 2,"level" => "info","msg" => "successfully upgraded database","time" => "2020-07-11T15:07:50Z"},
    ]
  end

  it 'executes upgrade with no arguments' do
    expect(Open3).to receive(:capture3).with('sensu-backend upgrade --skip-confirm').and_return(["", output, 0])
    ret = described_class.upgrade({})
    expect(ret).to eq(logs)
  end

  it 'handles arguments' do
    expected_cmd = 'sensu-backend upgrade --skip-confirm --config-file /etc/foo.yml --timeout 10 --etcd-client-cert-auth --etcd-cipher-suites foo bar'
    params = {
      '_task': 'sensu::backend_upgrade',
      'config_file': '/etc/foo.yml',
      'timeout': 10,
      'etcd_client_cert_auth': true,
      'etcd_cipher_suites': ['foo','bar'],
    }
    expect(Open3).to receive(:capture3).with(expected_cmd).and_return(["", output, 0])
    described_class.upgrade(params)
  end
end
