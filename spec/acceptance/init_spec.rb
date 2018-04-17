require 'spec_helper_acceptance'

describe 'sensu class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'sensu' do
    context 'default' do
      it 'should work without errors' do
        pp = <<-EOS
        include ::sensu
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end

      describe file('/etc/sensu') do
        it { should be_directory }
      end
    end
  end
end
