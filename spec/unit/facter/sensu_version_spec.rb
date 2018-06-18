require "spec_helper"

describe "Facter::Util::Fact" do
  context "on not windows" do
    before {
      Facter.clear
      allow(Facter.fact(:kernel)).to receive(:value).and_return('NotWindows')
    }
    describe 'returns sensu version when present' do
      it do
        allow(Facter::Util::Resolution).to receive(:which).with('sensu-agent').and_return('/bin/sensu-agent')
        allow(Facter::Util::Resolution).to receive(:exec).with('/bin/sensu-agent version 2>&1').and_return('sensu-agent version 2.0.0-nightly#9f6fee1, build 9f6fee1926ab1cfc93f03a32e8c1d46a28319732, built 2018-05-18T09:22:57+000')
        expect(Facter.fact(:sensu_version).value).to eql('2.0.0-nightly#9f6fee1')
      end
    end

    describe 'returns nil when sensu is not present' do
      it do
        allow(Facter::Util::Resolution).to receive(:which).with('sensu-agent').and_return(nil)
        expect(Facter.fact(:sensu_version).value).to be_nil
      end
    end
  end

  context "on windows" do
    before {
      Facter.clear
      allow(Facter.fact(:kernel)).to receive(:value).and_return('windows')
    }
    describe 'returns sensu version when present' do
      it do
        allow(File).to receive(:exists?).with('C:\opt\sensu\embedded\bin\sensu-agent.bat').and_return(true)
        allow(Facter::Util::Resolution).to receive(:exec).with('C:\opt\sensu\embedded\bin\sensu-agent.bat version 2>&1').and_return('sensu-agent version 2.0.0-nightly#9f6fee1, build 9f6fee1926ab1cfc93f03a32e8c1d46a28319732, built 2018-05-18T09:22:57+0000')
        expect(Facter.fact(:sensu_version).value).to eql('2.0.0-nightly#9f6fee1')
      end
    end

    describe 'returns nil when sensu is not present' do
      it do
        allow(File).to receive(:exists?).with('C:\opt\sensu\embedded\bin\sensu-agent.bat').and_return(false)
        expect(Facter.fact(:sensu_version).value).to be_nil
      end
    end
  end
end
