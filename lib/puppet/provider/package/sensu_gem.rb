require 'puppet/provider/package'
require 'uri'

# Ruby gems support.
Puppet::Type.type(:package).provide :sensu_gem, :parent => :gem do
  desc "Sensu Embedded Ruby Gem support. If a URL is passed via `source`, then
    that URL is used as the remote gem repository; if a source is present but is
    not a valid URL, it will be interpreted as the path to a local gem file.  If
    source is not present at all, the gem will be installed from the default gem
    repositories."

  has_feature :versionable, :install_options

  commands :gemcmd =>
    if RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|winse|emx/
      "#{ENV['SYSTEMDRIVE']}\\opt\\sensu\\embedded\\bin\\gem.cmd"
    else
      # grab the newest version available of the embedded ruby
      embedded_rvm_version = Dir.glob(File.join('/opt/sensu/embedded/lib/ruby/gems/', '*')).max { |a,b| File.ctime(a) <=> File.ctime(b) }
      ENV['GEM_PATH'] = "/opt/sensu/embedded/lib/ruby/gems/#{embedded_rvm_version}"
      "/opt/sensu/embedded/bin/gem"
    end

  def uninstall
    command = [command(:gemcmd), "uninstall"]
    command << "-x" << "-a" << resource[:name]
    output = execute(command)

    # Apparently some stupid gem versions don't exit non-0 on failure
    self.fail "Could not uninstall: #{output.chomp}" if output.include?("ERROR")
  end

end
