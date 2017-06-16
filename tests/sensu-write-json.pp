$h = {
  'string'        => 'val',
  'array'         => ['one', 2],
  'hash'          => {
    'one'   => 'one',
    'two'   => 2,
    'hash2' => {
      'works' => true,
    }
  },
  'array_of_hash' => [
    {'one' => 1},
    {'two' => 2},
  ],
}

sensu::write_json { '/tmp/sensu.json':
  owner   => $::id,
  group   => $::gid,
  content => $h,
}
