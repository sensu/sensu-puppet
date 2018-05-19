# private class
class sensu::repo {

  if $::sensu::repo_class {
    contain $::sensu::repo_class
  }

}

