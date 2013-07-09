class cinder::volume($volume_procs='1') inherits cinder {

  package {'cinder-volume':
    ensure => installed,
  }

  service {'cinder-volume':
    ensure    => running,
    subscribe => [ File['/etc/cinder/cinder.conf'],
                   File['/etc/cinder/api-paste.ini']],
    require   => Package['cinder-volume'],
  }

  nagios::nrpe::service { 'service_cinder_volume':
    check_command => '/usr/lib/nagios/plugins/check_procs -c ${procs}:${procs} -u cinder -a /usr/bin/cinder-volume';
  }

}
