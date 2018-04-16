require "spec_helper"

describe "Facter::Util::Fact" do
  context "on not windows" do
    before {
      Facter.clear
      allow(Facter.fact(:kernel)).to receive(:value).and_return('NotWindows')
    }
    describe 'returns sensu version when present' do
      it do
        allow(File).to receive(:exists?).with('/opt/sensu/embedded/bin/sensu-client').and_return(true)
        allow(Facter::Util::Resolution).to receive(:exec).with('/opt/sensu/embedded/bin/sensu-client --version 2>&1').and_return('0.23.3')
        expect(Facter.fact(:sensu_version).value).to eql('0.23.3')
      end
    end

    describe 'returns nil when sensu is not present' do
      it do
        allow(File).to receive(:exists?).with('/opt/sensu/embedded/bin/sensu-client').and_return(false)
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
        allow(File).to receive(:exists?).with('C:\opt\sensu\embedded\bin\sensu-client.bat').and_return(true)
        allow(Facter::Util::Resolution).to receive(:exec).with('C:\opt\sensu\embedded\bin\sensu-client.bat --version 2>&1').and_return('0.23.3')
        expect(Facter.fact(:sensu_version).value).to eql('0.23.3')
      end
    end

    describe 'returns nil when sensu is not present' do
      it do
        allow(File).to receive(:exists?).with('C:\opt\sensu\embedded\bin\sensu-client.bat').and_return(false)
        expect(Facter.fact(:sensu_version).value).to be_nil
      end
    end
  end
end
