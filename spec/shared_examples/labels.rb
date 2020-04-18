require 'spec_helper'

RSpec.shared_examples 'labels' do
  context 'labels' do
    it 'should accept a hash' do
      config[:labels] = {'foo' => 'bar'}
      expect(res[:labels]).to eq({'foo' => 'bar'})
    end
    it 'requires a hash' do
      config[:labels] = 'foo'
      expect { res }.to raise_error(/must be a Hash/)
    end
    it 'should not accept integer values' do
      config[:labels] = {'foo' => 1}
      expect { res }.to raise_error(/must be a String/)
    end
    it 'should be in sync' do
      config[:labels] = {'foo' => 'bar'}
      expect(res.property(:labels).insync?({'foo' => 'bar'})).to eq(true)
    end
    it 'should be in sync with ignored labels' do
      config[:labels] = {'foo' => 'bar'}
      expect(res.property(:labels).insync?({'foo' => 'bar', 'sensu.io/managed_by' => 'sensuctl'})).to eq(true)
    end
    it 'should be in sync regardless of hash order' do
      config[:labels] = {'foo' => 'bar', 'bar' => 'baz'}
      expect(res.property(:labels).insync?({'bar' => 'baz', 'foo' => 'bar'})).to eq(true)
    end
    it 'should not be in sync' do
      config[:labels] = {'foo' => 'baz'}
      expect(res.property(:labels).insync?({'foo' => 'bar'})).to eq(false)
    end
  end
end
