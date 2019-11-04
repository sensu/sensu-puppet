require 'serverspec'

set :backend, :cmd

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  # Only used to test Bolt
  c.add_setting :skip_apply, default: false
  c.skip_apply = (ENV['BEAKER_skip_apply'] == 'yes' || ENV['BEAKER_skip_apply'] == 'true')
  c.before :suite do
    bolt_cfg = <<-EOS
modulepath: "C:/ProgramData/PuppetLabs/code/environments/production/modules"
EOS
    require 'fileutils'
    home = File.expand_path('~')
    FileUtils.mkdir_p(File.join(home, '.puppetlabs\bolt'))
    File.open(File.join(home, '.puppetlabs\bolt\bolt.yaml'), 'w') { |f| f.write(bolt_cfg) }
  end
end
