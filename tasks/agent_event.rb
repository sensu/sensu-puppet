#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'net/http'

begin
  params = JSON.parse(STDIN.read)
  name = params['name']
  status = params['status']
  output = params['output']
  ttl = params['ttl']
  port = params['port'] || 3031

  data = {
    "check": {
      "metadata": {
        "name": name,
      },
      "status": status,
      "output": output,
    }
  }
  data['ttl'] = ttl unless ttl.nil?

  http = Net::HTTP.new('localhost', port)
  request = Net::HTTP::Post.new('/events', "Content-Type" => "application/json")
  request.body = data.to_json
  response = http.request(request)
  if response.kind_of?(Net::HTTPSuccess)
    puts({ status: "agent event successful" }.to_json)
  else
    puts({ status: "agent event failure: #{response.code}"}.to_json)
  end
rescue Exception => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
exit 0
