require 'puppet/provider/package'

# Sensu Embedded Ruby gems support.
Puppet::Type.type(:package).provide :sensu_gem, :parent => :gem do
  desc "Sensu Embedded Ruby Gem support. If a URL is passed via `source`, then that URL is
    appended to the list of remote gem repositories; to ensure that only the
    specified source is used, also pass `--clear-sources` via `install_options`.
    If source is present but is not a valid URL, it will be interpreted as the
    path to a local gem file. If source is not present, the gem will be
    installed from the default gem repositories. Note that to modify this for Windows, it has to be a valid URL.
    This provider supports the `install_options` and `uninstall_options` attributes,
    which allow command-line flags to be passed to the gem command.
    These options should be specified as an array where each element is either a 
    string or a hash."


  has_feature :versionable, :install_options, :uninstall_options, :targetable

  commands :gemcmd => "/opt/sensu-plugins-ruby/embedded/bin/gem"
end
