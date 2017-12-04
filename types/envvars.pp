type Sensu::Envvars = Struct[{

  Optional['EMBEDDED_RUBY'] => Boolean,
  Optional['CONFIG_FILE'] => Optional[Stdlib::Absolutepath],
  Optional['CONFD_DIR'] => Optional[Stdlib::Absolutepath],
  Optional['EXTENSION_DIR'] => Optional[Stdlib::Absolutepath],
  Optional['PLUGINS_DIR'] => Optional[Stdlib::Absolutepath],
  Optional['HANDLERS_DIR'] => Optional[Stdlib::Absolutepath],
  Optional['LOG_DIR'] => Optional[Stdlib::Absolutepath],
  Optional['LOG_LEVEL'] => Enum['debug','info','warn','error','fatal'],
  Optional['PID_DIR'] => Optional[Stdlib::Absolutepath],
  Optional['USER'] => Optional[String],
  Optional['SERVICE_MAX_WAIT'] => Integer,

  Optional['RUBYOPT'] => Optional[Stdlib::Absolutepath],
  Optional['GEM_PATH'] => Optional[String],
  Optional['CLIENT_DEREGISTER_ON_STOP'] => Boolean,
  Optional['CLIENT_DEREGISTER_HANDLER'] => Stdlib::Absolutepath,
  Optional['PATH'] => Optional[String],

}]
