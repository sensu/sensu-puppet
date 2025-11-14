require 'spec_helper'
require 'facter/sensu_facts' # Load the file under test

describe 'sensu_facts' do
  before(:each) do
    Facter.clear
  end
  describe 'sensu_agent fact' do
    it 'returns version information' do
      allow(Facter).to receive(:which).with('sensu-agent').and_return('/bin/sensu-agent')
      sensu_agent_version_output = "sensu-agent version 6.2.0, enterprise edition, build 12345, built 2023-10-26"
      allow(Facter::Core::Execution).to receive(:execute).with('/bin/sensu-agent version', timeout: 10).and_return(sensu_agent_version_output)
      expect(Facter.fact(:sensu_agent_version).value).to eq('6.2.0')
    end
  end
end