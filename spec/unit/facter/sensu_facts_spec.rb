require "spec_helper"
require 'facter/sensu_facts'

describe "SensuFacts" do
  context 'sensu_agent fact' do
    it 'returns version information' do
      allow(SensuFacts).to receive(:which).with('sensu-agent').and_return('/bin/sensu-agent')
      allow(Facter::Core::Execution).to receive(:exec).with('/bin/sensu-agent version 2>&1').and_return("sensu-agent version 5.1.0#b2ea9fc, build b2ea9fcdb21e236e6e9a7de12225a6d90c786c57, built '2018-12-18T21:31:11+0000'")
      SensuFacts.add_agent_facts
      expect(Facter.fact(:sensu_agent).value).to eq({'version' => '5.1.0', 'build' => 'b2ea9fcdb21e236e6e9a7de12225a6d90c786c57', 'built' => '2018-12-18T21:31:11+0000'})
    end

    it 'returns nil' do
      allow(SensuFacts).to receive(:which).with('sensu-agent').and_return(nil)
      SensuFacts.add_agent_facts
      expect(Facter.fact(:sensu_agent).value).to be_nil
    end
  end

  context 'sensu_backend fact' do
    it 'returns version information' do
      allow(SensuFacts).to receive(:which).with('sensu-backend').and_return('/bin/sensu-backend')
      allow(Facter::Core::Execution).to receive(:exec).with('/bin/sensu-backend version 2>&1').and_return("sensu-backend version 5.1.0#b2ea9fc, build b2ea9fcdb21e236e6e9a7de12225a6d90c786c57, built '2018-12-18T21:31:11+0000'")
      SensuFacts.add_backend_facts
      expect(Facter.fact(:sensu_backend).value).to eq({'version' => '5.1.0', 'build' => 'b2ea9fcdb21e236e6e9a7de12225a6d90c786c57', 'built' => '2018-12-18T21:31:11+0000'})
    end

    it 'returns nil' do
      allow(Facter::Core::Execution).to receive(:which).with('sensu-backend').and_return(nil)
      SensuFacts.add_backend_facts
      expect(Facter.fact(:sensu_backend).value).to be_nil
    end
  end

  context 'sensuctl fact' do
    it 'returns version information' do
      allow(SensuFacts).to receive(:which).with('sensuctl').and_return('/bin/sensuctl')
      allow(Facter::Core::Execution).to receive(:exec).with('/bin/sensuctl version 2>&1').and_return("sensuctl version 5.1.0#b2ea9fc, build b2ea9fcdb21e236e6e9a7de12225a6d90c786c57, built '2018-12-18T21:31:11+0000'")
      SensuFacts.add_sensuctl_facts
      expect(Facter.fact(:sensuctl).value).to eq({'version' => '5.1.0', 'build' => 'b2ea9fcdb21e236e6e9a7de12225a6d90c786c57', 'built' => '2018-12-18T21:31:11+0000'})
    end

    it 'returns nil' do
      allow(SensuFacts).to receive(:which).with('sensuctl').and_return(nil)
      SensuFacts.add_sensuctl_facts
      expect(Facter.fact(:sensuctl).value).to be_nil
    end
  end
end
