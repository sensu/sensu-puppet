require 'spec_helper'
require 'puppet/functions/sensu/password_hash'

describe 'sensu::password_hash' do
  it 'should generate hash using sensuctl' do
    allow(SensuctlHashpass).to receive(:which_sensuctl).and_return('/usr/bin/sensuctl')
    allow(SensuctlHashpass).to receive(:get_hashpass).with('password').and_return('$1$hash')
    is_expected.to run.with_params('password').and_return('$1$hash')
  end

  it 'should fail if no sensuctl or bcrypt' do
    allow(SensuctlHashpass).to receive(:which_sensuctl).and_return(nil)
    expect(SensuctlHashpass).not_to receive(:get_hashpass)
    allow(SensuctlHashpass).to receive(:bcrypt?).and_return(false)
    is_expected.to run.with_params('password').and_raise_error(RuntimeError, /sensuctl not found and bcrypt not present/)
  end

  it 'should fallback to bcrypt' do
    require 'bcrypt'
    allow(SensuctlHashpass).to receive(:bcrypt?).and_return(true)
    allow(BCrypt::Password).to receive(:create).and_return('$1$hash')
    is_expected.to run.with_params('password').and_return('$1$hash')
  end
end

