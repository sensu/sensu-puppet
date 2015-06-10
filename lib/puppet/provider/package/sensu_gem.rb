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

  commands :gemcmd => "/opt/sensu/embedded/bin/gem"

  def uninstall
    command = [command(:gemcmd), "uninstall"]
    command << "-x" << "-a" << resource[:name]
    output = execute(command)

    # Apparently some stupid gem versions don't exit non-0 on failure
    self.fail "Could not uninstall: #{output.chomp}" if output.include?("ERROR")
  end

end
