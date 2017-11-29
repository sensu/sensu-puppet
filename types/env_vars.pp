type Sensu::Env_Vars = Struct[{

  Optional[EMBEDDED_RUBY] => Boolean,
  Optional[LOG_LEVEL] => Enum['debug','info','warn','error','fatal'],
  Optional[LOG_DIR] => Stdlib::Absolutepath,
  Optional[RUBYOPT] => Stdlib::Absolutepath,
  Optional[GEM_PATH] => String,
  Optional[CLIENT_DEREGISTER_ON_STOP] => Boolean,
  Optional[SERVICE_MAX_WAIT] => Stdlib::Absolutepath,
  Optional[CLIENT_DEREGISTER_HANDLER] => Stdlib::Absolutepath,
  Optional[PATH] => String,
  Optional[CONFD_DIR] => String,

}]
