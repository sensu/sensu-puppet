# = Define: sensu::plugin
#
# Installs the Sensu plugins
#
# == Parameters
#

define sensu::plugin(
  $install_path = '/etc/sensu/plugins'
){

  $filename = inline_template("<%= scope.lookupvar('name').split('/').last %>")

  file { "${install_path}/${filename}":
    ensure  => file,
    mode    => '0555',
    source  => $name
  }
}
