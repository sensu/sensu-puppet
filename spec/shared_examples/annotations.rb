require 'spec_helper'

RSpec.shared_examples 'annotations' do
  context 'annotations' do
    it 'should accept a hash with string values' do
      config[:annotations] = {'foo' => 'bar'}
      expect(res[:annotations]).to eq({'foo' => 'bar'})
    end
    it 'should accept array values' do
      config[:annotations] = {'foo' => ['bar', 'baz']}
      expect(res[:annotations]).to eq({'foo' => ['bar', 'baz']})
    end
    it 'should accept hash values' do
      config[:annotations] = {'foo' => {'bar' => 'baz'}}
      expect(res[:annotations]).to eq({'foo' => {'bar' => 'baz'}})
    end
    it 'requires a hash' do
      config[:annotations] = 'foo'
      expect { res }.to raise_error(/should be a Hash/)
    end
  end
end
