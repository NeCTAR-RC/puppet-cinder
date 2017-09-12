class cinder::backup inherits cinder {

  package {'cinder-backup':
    ensure => installed,
    tag    => 'openstack',
  }

  service {'cinder-backup':
    ensure    => running,
    subscribe => [ File['/etc/cinder/cinder.conf'],
                   File['/etc/cinder/api-paste.ini']],
    require   => Package['cinder-backup'],
  }

  nagios::nrpe::service { 'service_cinder_backup':
    check_command => '/usr/lib/nagios/plugins/check_procs -c 1:20 -u cinder -a bin/cinder-backup';
  }

}
