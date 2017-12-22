type Sensu::Envvarsenterprise = Struct[{

  Optional['HEAP_SIZE'] => Variant[Undef,Integer,Pattern[/^(\d+)/]],
  Optional['HEAP_DUMP_PATH'] => Optional[Stdlib::Absolutepath],
  Optional['JAVA_OPTS'] => Optional[String],
  Optional['MAX_OPEN_FILES'] => Variant[Undef,Integer,Pattern[/^(\d+)$/]],

}]
