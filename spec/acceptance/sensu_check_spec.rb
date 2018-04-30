require 'spec_helper_acceptance'

describe 'sensu_check', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_check { 'test':
        command       => 'check-http.rb',
        subscriptions => ['demo'],
        handlers      => ['email'],
        interval      => 60,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

  end
end

