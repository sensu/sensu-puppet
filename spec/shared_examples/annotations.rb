require 'spec_helper'

RSpec.shared_examples 'annotations' do
  context 'annotations' do
    it 'should accept a hash' do
      config[:annotations] = {'foo' => 'bar'}
      expect(res[:annotations]).to eq({'foo' => 'bar'})
    end
    it 'requires a hash' do
      config[:annotations] = 'foo'
      expect { res }.to raise_error(/must be a Hash/)
    end
    it 'should not accept integer values' do
      config[:annotations] = {'foo' => 1}
      expect { res }.to raise_error(/must be a String/)
    end
  end
end
