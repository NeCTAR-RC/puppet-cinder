class cinder {

  file { '/etc/cinder/cinder.conf':
    ensure  => present,
    owner   => cinder,
    group   => cinder,
    mode    => '0600',
    content => template("cinder/cinder.conf-${openstack_version}.erb"),
  }

  file { '/etc/cinder/api-paste.ini':
    ensure  => present,
    owner   => cinder,
    group   => cinder,
    mode    => '0600',
    content => template("cinder/api-paste.ini-${openstack_version}.erb"),
  }
  
}
