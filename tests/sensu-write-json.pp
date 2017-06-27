$h = {
  'string'        => 'val',
  'array'         => ['one', 2],
  'hash'          => {
    'one'   => 'one',
    'two'   => 2,
    'hash2' => {
      'works' => true,
    },
  },
  'array_of_hash' => [
    {'one' => 1},
    {'two' => 2},
  ],
}

sensu::write_json { '/tmp/sensu.json':
  content => $h,
}

sensu::write_json { '/tmp/sensu-owner.json':
  owner   => 'root',
  content => $h,
}

sensu::write_json { '/tmp/sensu-group.json':
  group   => 'root',
  content => $h,
}

sensu::write_json { '/tmp/sensu-mode.json':
  mode    => '0777',
  content => $h,
}

sensu::write_json { '/tmp/sensu-ugly.json':
  pretty  => false,
  content => $h,
}
