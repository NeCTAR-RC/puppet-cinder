class cinder::scheduler inherits cinder {

  package {'cinder-scheduler':
    ensure => installed,
  }

  service {'cinder-scheduler':
    ensure    => running,
    subscribe => [ File['/etc/cinder/cinder.conf']
                   File['/etc/cinder/api-paste.ini']],
    require   => Package['cinder-scheduler'],
  }
  
}
