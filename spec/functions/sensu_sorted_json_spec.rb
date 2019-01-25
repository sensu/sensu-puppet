require 'spec_helper'
describe 'sensu_sorted_json' do
  it { is_expected.not_to eq(nil) }

  describe 'should error when expected' do
    it { is_expected.to run.with_params.and_raise_error(/expects between 1 and 2 arguments, got none/) }
    it { is_expected.to run.with_params(1,2,3).and_raise_error(/expects between 1 and 2 arguments, got 3/) }
  end

  input_hash = {
    "bind_addr"=>"192.168.34.56",
    "client_addr"=>"127.0.0.1",
    "ports"=>{"http"=>-1,"https"=>8500,"rpc"=>8567},
    "start_join"=>["192.168.34.60","192.168.34.61","192.168.34.62"],
  }

  valid_pretty_hash = <<-END.gsub(/^\s+\|/, '')
    |{
    |    "bind_addr": "192.168.34.56",
    |    "client_addr": "127.0.0.1",
    |    "ports": {
    |        "http": -1,
    |        "https": 8500,
    |        "rpc": 8567
    |    },
    |    "start_join": [
    |        "192.168.34.60",
    |        "192.168.34.61",
    |        "192.168.34.62"
    |    ]
    |}
  END

  valid_ugly_hash = "{\"bind_addr\":\"192.168.34.56\",\"client_addr\":\"127.0.0.1\",\"ports\":{\"http\":-1,\"https\":8500,\"rpc\":8567},\"start_join\":[\"192.168.34.60\",\"192.168.34.61\",\"192.168.34.62\"]}"

  describe 'should return correct results' do
    it 'should run with only valid hash specified' do
      is_expected.to run.with_params(input_hash).and_return(valid_ugly_hash)
    end

    it 'should run with valid hash and pretty set to true' do
      is_expected.to run.with_params(input_hash, true).and_return(valid_pretty_hash)
    end

    it 'should run with valid hash and pretty set to false' do
      is_expected.to run.with_params(input_hash, false).and_return(valid_ugly_hash)
    end
  end
end
