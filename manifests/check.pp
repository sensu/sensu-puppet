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
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*handlers*]
#   Array of Strings.  Handlers to use for this check
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*standalone*]
#   Boolean.  When true, scheduled by the client.  When false, listen for published check request
#   Set this to 'absent' to remove it completely.
#   Default: true
#
# [*interval*]
#   Integer.  How frequently (in seconds) the check will be executed
#   Set this to 'absent' to remove it completely.
#   Default: 60
#
# [*occurrences*]
#   Integer.  The number of event occurrences before the handler should take action.
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*refresh*]
#   Integer.  The number of seconds sensu-plugin-aware handlers should wait before taking second action.
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*source*]
#   String.  The check source, used to create a JIT Sensu client for an external resource (e.g. a network switch).
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*subscribers*]
#   Array of Strings.  Which subscriptions must execute this check
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*low_flap_threshold*]
#   Integer.  Flap detection - see Nagios Flap Detection: http://nagios.sourceforge.net/docs/3_0/flapping.html
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*high_flap_threshold*]
#   Integer.  Flap detection - see Nagios Flap Detection: http://nagios.sourceforge.net/docs/3_0/flapping.html
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*timeout*]
#   Numeric.  Check timeout in seconds, after it fails
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*aggregate*]
#   String.  Aggregates, preventing event floods. Set 'aggregate:<name> and 'handle':false, this prevents the
#   server from sending to a handler, and makes the aggregated results available under /aggregates in the REST API
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*aggregates*]
#   Array of Strings. An array of aggregates to add to the check. This supercedes the above aggregate parameter
#   Set this to 'absent' to remove it completely.
#   Defaults: undef
#
# [*handle*]
#   Boolean.  When false, check will not be sent to handlers
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*publish*]
#   Boolean.  Unpublished checks. Prevents the check from being triggered on clients. This allows for the definition
#   of commands that are not actually 'checks' per say, but actually arbitrary commands for remediation
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*dependencies*]
#   Array.  List of checks this check depends on.  Note: The validity of the other checks is not enforced by puppet
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*ttl*]
#   Integer. The time to live (TTL) in seconds until check results are considered stale.
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
# [*subdue*]
#   Hash.  Check subdue configuration
#   Set this to 'absent' to remove it completely.
#   Default: undef
#
define sensu::check(
  $command,
  $ensure              = 'present',
  $type                = undef,
  $handlers            = undef,
  $standalone          = true,
  $interval            = 60,
  $occurrences         = undef,
  $refresh             = undef,
  $source              = undef,
  $subscribers         = undef,
  $low_flap_threshold  = undef,
  $high_flap_threshold = undef,
  $timeout             = undef,
  $aggregate           = undef,
  $aggregates          = undef,
  $handle              = undef,
  $publish             = undef,
  $dependencies        = undef,
  $custom              = undef,
  $ttl                 = undef,
  $subdue              = undef,
) {

  validate_re($ensure, ['^present$', '^absent$'] )
  if !is_bool($standalone) and  $standalone != 'absent' {
    fail("sensu::check{${name}}: standalone must be a boolean or 'absent' (got: ${standalone})")
  }
  if $handle and !is_bool($handle) and  $handle != 'absent' {
    fail("sensu::check{${name}}: handle must be a boolean or 'absent' (got: ${handle})")
  }
  if $publish and !is_bool($publish) and  $publish != 'absent' {
    fail("sensu::check{${name}}: publish must be a boolean or 'absent' (got: ${publish})")
  }
  if !is_integer($interval) and $interval != 'absent' {
    fail("sensu::check{${name}}: interval must be an integer or 'absent' (got: ${interval})")
  }
  if $occurrences and !is_integer($occurrences) and $occurrences != 'absent' {
    fail("sensu::check{${name}}: occurrences must be an integer or 'absent' (got: ${occurrences})")
  }
  if $refresh and !is_integer($refresh) and $refresh != 'absent' {
    fail("sensu::check{${name}}: refresh must be an integer or 'absent' (got: ${refresh})")
  }
  if $low_flap_threshold and !is_integer($low_flap_threshold) and $low_flap_threshold != 'absent' {
    fail("sensu::check{${name}}: low_flap_threshold must be an integer or 'absent' (got: ${low_flap_threshold})")
  }
  if $high_flap_threshold and !is_integer($high_flap_threshold) and $high_flap_threshold != 'absent' {
    fail("sensu::check{${name}}: high_flap_threshold must be an integer or 'absent' (got: ${high_flap_threshold})")
  }
  if $timeout and !is_numeric($timeout) and $timeout != 'absent' {
    fail("sensu::check{${name}}: timeout must be a numeric or 'absent' (got: ${timeout})")
  }
  if $ttl and !is_integer($ttl) and $ttl != 'absent' {
    fail("sensu::check{${name}}: ttl must be an integer or 'absent' (got: ${ttl})")
  }
  if $dependencies and !is_array($dependencies) and !is_string($dependencies) {
    fail("sensu::check{${name}}: dependencies must be an array or a string (got: ${dependencies})")
  }
  if $handlers and !is_array($handlers) and !is_string($handlers) {
    fail("sensu::check{${name}}: handlers must be an array or a string (got: ${handlers})")
  }
  if $subscribers and !is_array($subscribers) and !is_string($subscribers) {
    fail("sensu::check{${name}}: subscribers must be an array or a string (got: ${subscribers})")
  }
  if $subdue {
    if is_hash($subdue) {
      if !( has_key($subdue, 'days') and is_hash($subdue['days']) ){
        fail("sensu::check{${name}}: subdue hash should have a proper format. (got: ${subdue}) See https://sensuapp.org/docs/latest/reference/checks.html#subdue-attributes")
      }
    } elsif !($subdue == 'absent') {
      fail("sensu::check{${name}}: subdue must be a hash or 'absent' (got: ${subdue})")
    }
  }
  if $aggregates and !is_array($aggregates) and !is_string($aggregates) {
    fail("sensu::check{${name}}: aggregates must be an array or a string (got: ${aggregates})")
  }

  $check_name = regsubst(regsubst($name, ' ', '_', 'G'), '[\(\)]', '', 'G')

  case $::osfamily {
    'windows': {
      $etc_dir = 'C:/opt/sensu'
      $conf_dir = "${etc_dir}/conf.d"
      $user = undef
      $group = undef
      $file_mode = undef
    }
    default: {
      $etc_dir = '/etc/sensu'
      $conf_dir = "${etc_dir}/conf.d"
      $user = 'sensu'
      $group = 'sensu'
      $file_mode = '0440'
    }
  }

  file { "${conf_dir}/checks/${check_name}.json":
    ensure => $ensure,
    owner  => $user,
    group  => $group,
    mode   => $file_mode,
    before => Sensu_check[$check_name],
  }

  sensu_check { $check_name:
    ensure              => $ensure,
    base_path           => "${conf_dir}/checks",
    type                => $type,
    standalone          => $standalone,
    command             => $command,
    handlers            => $handlers,
    interval            => $interval,
    occurrences         => $occurrences,
    refresh             => $refresh,
    source              => $source,
    subscribers         => $subscribers,
    low_flap_threshold  => $low_flap_threshold,
    high_flap_threshold => $high_flap_threshold,
    timeout             => $timeout,
    aggregate           => $aggregate,
    aggregates          => $aggregates,
    handle              => $handle,
    publish             => $publish,
    dependencies        => $dependencies,
    custom              => $custom,
    subdue              => $subdue,
    require             => File["${conf_dir}/checks"],
    notify              => $::sensu::check_notify,
    ttl                 => $ttl,
  }

}
