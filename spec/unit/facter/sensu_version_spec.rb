require "spec_helper"

describe "Facter::Util::Fact" do
  context "on linux" do
    before {
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns('Linux')
    }
    describe 'returns sensu version when present' do
        it do
          File.stubs(:exists?).with('/opt/sensu/embedded/bin/sensu-client').returns(true)
          Facter::Util::Resolution.expects(:exec).with('/opt/sensu/embedded/bin/sensu-client --version 2>&1').returns('0.23.3')
          expect(Facter.value(:sensu_version)).to eql('0.23.3')
        end
    end

    describe 'returns nil when sensu is not present' do
        it do
          File.stubs(:exists?).with('/opt/sensu/embedded/bin/sensu-client').returns(false)
          expect(Facter.value(:sensu_version)).to be_nil
        end
    end
  end

  context "on windows" do
    before {
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns('windows')
    }
    describe 'returns sensu version when present' do
        it do
          File.stubs(:exists?).with('C:\opt\sensu\embedded\bin\sensu-client.bat').returns(true)
          Facter::Util::Resolution.expects(:exec).with('C:\opt\sensu\embedded\bin\sensu-client.bat --version 2>&1').returns('0.23.3')
          expect(Facter.value(:sensu_version)).to eql('0.23.3')
        end
    end

    describe 'returns nil when sensu is not present' do
        it do
          File.stubs(:exists?).with('C:\opt\sensu\embedded\bin\sensu-client.bat').returns(false)
          expect(Facter.value(:sensu_version)).to be_nil
        end
    end
  end
end
