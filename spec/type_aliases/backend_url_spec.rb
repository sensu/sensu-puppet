require 'spec_helper'

describe 'Sensu::Backend_URL' do
  context 'allows valid values' do
    [
      'localhost:8081',
      '127.0.0.1:8081',
      'ws://localhost:8081',
      'wss://localhost:8081',
      'ws://127.0.0.1:8081',
      'wss://127.0.0.1:8081',
      'test.example.com:8081',
      'ws://test.example.com:8081',
      'wss://test.example.com:8081',
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  context 'disallow invalid values' do
    [
      'http://localhost:8081',
      'localhost',
      'ws://localhost',
      'wss://localhost',
      '127.0.0.1',
      'ws://127.0.0.1',
      'wss://127.0.0.1',
      'foo bar',
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
