class cinder::volume inherits cinder {

  package {'cinder-volume':
    ensure => installed,
  }

  service {'cinder-volume':
    ensure    => running,
    subscribe => [ File['/etc/cinder/cinder.conf'],
                   File['/etc/cinder/api-paste.ini']],
    require   => Package['cinder-volume'],
  }
}
