# = Define: sensu::check
#
# Defines Sensu checks
#
# == Parameters
#
# [*command*]
#   String.  The check command to run
#   Default: undef
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

# [*contacts*]
#   Array of Strings.  Contacts to use for the contact-routing
#   Sensu Enterprise feature.  This value corresponds with a sensu::contact
#   resource having the same name.
#   Default: undef
#
# [*standalone*]
#   Boolean.  When true, scheduled by the client.  When false, listen for published check request
#   Set this to 'absent' to remove it completely.
#   Default: true
#
# [*cron*]
#   String.  When the check should be executed, using the [Cron
#   syntax](https://en.wikipedia.org/wiki/Cron#CRON_expression).  Supersedes the
#   `interval` parameter.  Example: `"0 0 * * *"`.
#   Default: 'absent'
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
# [*custom*]
#   Hash. List of custom attributes to include in the check. You can use it to pass any attribute that is not listed here explicitly.
#   Default: undef
#   Example: { 'remediation' => { 'low_remediation' => { 'occurrences' => [1,2], 'severities' => [1], 'command' => "/bin/command", 'publish' => false, } } }
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
# [*proxy_requests*]
#   Hash.  [Proxy Check
#   Requests](https://sensuapp.org/docs/latest/reference/checks.html#proxy-requests-attributes)
#   Since Sensu 0.28.0.  Publishes a check request to every Sensu client which
#   matches the defined client attributes.  See the documentation for the format
#   of the Hash value.
#   Default: undef
define sensu::check(
  Optional[String] $command = undef,
  Enum['present','absent'] $ensure              = 'present',
  Optional[String] $type                = undef,
  Variant[Undef,String,Array] $handlers            = undef,
  Optional[Array] $contacts            = undef,
  Variant[Boolean,Enum['absent']] $standalone          = true,
  String $cron                = 'absent',
  Variant[Integer,Enum['absent']] $interval            = 60,
  Variant[Undef,Pattern[/^(\d+)$/],Integer,Enum['absent']] $occurrences         = undef,
  Variant[Undef,Enum['absent'],Integer] $refresh             = undef,
  Variant[Undef,String,Integer] $source              = undef,
  Variant[Undef,String,Array] $subscribers         = undef,
  Variant[Undef,Enum['absent'],Integer] $low_flap_threshold  = undef,
  Variant[Undef,Enum['absent'],Integer] $high_flap_threshold = undef,
  Variant[Undef,Enum['absent'],Numeric] $timeout             = undef,
  Optional[String] $aggregate           = undef,
  Variant[Undef,String,Array] $aggregates          = undef,
  Variant[Undef,Enum['absent'],Boolean] $handle              = undef,
  Variant[Undef,Enum['absent'],Boolean] $publish             = undef,
  Variant[Undef,String,Array] $dependencies        = undef,
  Optional[Hash] $custom              = undef,
  Variant[Undef,Enum['absent'],Integer] $ttl                 = undef,
  Variant[Undef,Enum['absent'],Hash] $subdue              = undef,
  Variant[Undef,Enum['absent'],Hash] $proxy_requests      = undef,
) {

  if $ensure == 'present' and !$command {
    fail("sensu::check{${name}}: a command must be given when ensure is present")
  }

  if $subdue =~ Hash {
    if !( has_key($subdue, 'days') and $subdue['days'] =~ Hash ) {
      fail("sensu::check{${name}}: subdue hash should have a proper format. (got: ${subdue}) See https://sensuapp.org/docs/latest/reference/checks.html#subdue-attributes")
    }
  }
  if $proxy_requests {
    if $proxy_requests =~ Hash {
      if !( has_key($proxy_requests, 'client_attributes') ) {
        fail("sensu::check{${name}}: proxy_requests hash should have a proper format.  (got: ${proxy_requests})  See https://sensuapp.org/docs/latest/reference/checks.html#proxy-requests-attributes")
      }
    } elsif !($proxy_requests == 'absent') {
      fail("sensu::check{${name}}: proxy_requests must be a hash or 'absent' (got: ${proxy_requests})")
    }
  }

  $check_name = regsubst(regsubst($name, ' ', '_', 'G'), '[\(\)]', '', 'G')

  # If cron is specified, interval should not be written to the configuration
  if $cron and $cron != 'absent' {
    $interval_real = 'absent'
  } else {
    $interval_real = $interval
  }

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
    contacts            => $contacts,
    cron                => $cron,
    interval            => $interval_real,
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
    proxy_requests      => $proxy_requests,
    require             => File["${conf_dir}/checks"],
    notify              => $::sensu::check_notify,
    ttl                 => $ttl,
  }
}
