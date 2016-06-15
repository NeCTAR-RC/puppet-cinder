class cinder::scheduler inherits cinder {

  package {'cinder-scheduler':
    ensure => installed,
  }

  service {'cinder-scheduler':
    ensure    => running,
    subscribe => [ File['/etc/cinder/cinder.conf'],
                   File['/etc/cinder/api-paste.ini']],
    require   => Package['cinder-scheduler'],
  }

  nagios::nrpe::service { 'service_cinder_scheduler':
    check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u cinder -a bin/cinder-scheduler';
  }

}
