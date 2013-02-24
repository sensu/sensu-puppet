require 'spec_helper'

describe 'sensu::package', :type => :class do
  let(:facts) { { :fqdn => 'testhost.domain.com' } }

  it { should create_class('sensu::package') }
  it { should include_class('sensu::repo') }
  it { should contain_package('sensu').with_ensure('latest') }
  it { should contain_sensu_clean_config('testhost.domain.com') }

end
