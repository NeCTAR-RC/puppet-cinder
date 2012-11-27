class cinder::api inherits cinder {

  package {'cinder-api':
    ensure => installed,
  }

  service {'cinder-api':
    ensure    => running,
    subscribe => [ File['/etc/cinder/cinder.conf']
                   File['/etc/cinder/api-paste.ini']],
    require   => Package['cinder-api'],
  }

}
