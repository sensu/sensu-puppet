# = Define: sensu::check
#
# Defines Sensu checks
#
# == Parameters
#
# [*command*]
#   String.  The check command to run
#
# [*ensure*]
#   String. Whether the check should be present or not
#   Default: present
#   Valid values: present, absent
#
# [*type*]
#   String.  Type of check
#   Default: undef
#
# [*handlers*]
#   Array of Strings.  Handlers to use for this check
#   Default: undef
#
# [*standalone*]
#   Boolean.  When true, scheduled by the client.  When false, listen for published check request
#   Default: true
#
# [*interval*]
#   Integer.  How frequently (in seconds) the check will be executed
#   Default: 60
#
# [*subscribers*]
#   Array of Strings.  Which subscriptions must execute this check
#   Default: []
#
# [*low_flap_threshold*]
#   Integer.  Flap detection - see Nagios Flap Detection: http://nagios.sourceforge.net/docs/3_0/flapping.html
#   Default: undef
#
# [*high_flap_threshold*]
#   Integer.  Flap detection - see Nagios Flap Detection: http://nagios.sourceforge.net/docs/3_0/flapping.html
#   Default: undef
#
# [*timeout*]
#   Integer.  Check timeout in seconds, after it fails
#   Default: undef
#
# [*aggregate*]
#   Boolean.  Aggregates, preventing event floods. Set 'aggregate:true and 'handle':false, this prevents the
#   server from sending to a handler, and makes the aggregated results available under /aggregates in the REST API
#   Default: undef
#
# [*handle*]
#   Boolean.  When true, check will not be sent to handlers
#   Default: undef
#
# [*publish*]
#   Boolean.  Unpublished checks. Prevents the check from being triggered on clients. This allows for the definition
#   of commands that are not actually 'checks' per say, but actually arbitrary commands for remediation
#   Default: undef
#
define sensu::check(
  $command,
  $ensure              = 'present',
  $type                = undef,
  $handlers            = undef,
  $standalone          = true,
  $interval            = 60,
  $subscribers         = [],
  $low_flap_threshold  = undef,
  $high_flap_threshold = undef,
  $timeout             = undef,
  $aggregate           = undef,
  $handle              = undef,
  $publish             = undef,
  $custom              = undef,
) {

  validate_re($ensure, ['^present$', '^absent$'] )
  validate_bool($standalone)
  if !is_integer($interval) {
    fail("sensu::check{${name}}: interval must be an integer (got: ${interval})")
  }
  if $low_flap_threshold and !is_integer($low_flap_threshold) {
    fail("sensu::check{${name}}: low_flap_threshold must be an integer (got: ${low_flap_threshold})")
  }
  if $high_flap_threshold and !is_integer($high_flap_threshold) {
    fail("sensu::check{${name}}: high_flap_threshold must be an integer (got: ${high_flap_threshold})")
  }
  if $timeout and !is_float($timeout) {
    fail("sensu::check{${name}}: timeout must be an float (got: ${timeout})")
  }

  $check_name = regsubst(regsubst($name, ' ', '_', 'G'), '[\(\)]', '', 'G')

  file { "/etc/sensu/conf.d/checks/${check_name}.json":
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0440',
    before  => Sensu_check[$check_name],
  }

  sensu_check { $check_name:
    ensure              => $ensure,
    type                => $type,
    standalone          => $standalone,
    command             => $command,
    handlers            => $handlers,
    interval            => $interval,
    subscribers         => $subscribers,
    low_flap_threshold  => $low_flap_threshold,
    high_flap_threshold => $high_flap_threshold,
    timeout             => $timeout,
    aggregate           => $aggregate,
    handle              => $handle,
    publish             => $publish,
    custom              => $custom,
    require             => File['/etc/sensu/conf.d/checks'],
    notify              => [ Class['sensu::client::service'], Class['sensu::server::service'] ],
  }

}
