require 'spec_helper'

RSpec.shared_examples 'secrets property' do
  describe 'secrets' do
    it 'accepts valid value' do
      config[:secrets] = [{'name' => 'SECRET', 'secret' => 'test'}]
      expect(res[:secrets]).to eq([{'name' => 'SECRET', 'secret' => 'test'}])
    end
    it 'should require Hash elements' do
      config[:secrets] = ['foo']
      expect { res }.to raise_error(Puppet::Error, /secrets elements must be a Hash/)
    end
    it 'does not accept invalid keys' do
      config[:secrets] = [{'name' => 'SECRET', 'secret' => 'test', 'foo' => 'bar'}]
      expect { res }.to raise_error(/foo/)
    end
    it 'requires name' do
      config[:secrets] = [{'secret' => 'test'}]
      expect { res }.to raise_error(/name/)
    end
    it 'requires secret' do
      config[:secrets] = [{'name' => 'SECRET'}]
      expect { res }.to raise_error(/secret/)
    end
  end
end
