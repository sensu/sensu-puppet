type Sensu::Envvars = Struct[{

  Optional['EMBEDDED_RUBY'] => Boolean,
  Optional['LOG_LEVEL'] => Enum['debug','info','warn','error','fatal'],
  Optional['LOG_DIR'] => Optional[Stdlib::Absolutepath],
  Optional['RUBYOPT'] => Optional[Stdlib::Absolutepath],
  Optional['GEM_PATH'] => Optional[String],
  Optional['CLIENT_DEREGISTER_ON_STOP'] => Boolean,
  Optional['SERVICE_MAX_WAIT'] => Stdlib::Absolutepath,
  Optional['CLIENT_DEREGISTER_HANDLER'] => Stdlib::Absolutepath,
  Optional['PATH'] => Optional[String],
  Optional['CONFD_DIR'] => Optional[Stdlib::Absolutepath],

}]
