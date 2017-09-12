class cinder::volume inherits cinder {

  package {'cinder-volume':
    ensure => installed,
    tag    => 'openstack',
  }

  service {'cinder-volume':
    ensure    => running,
    subscribe => [ File['/etc/cinder/cinder.conf'],
                   File['/etc/cinder/api-paste.ini']],
    require   => Package['cinder-volume'],
  }

  nagios::nrpe::service { 'service_cinder_volume':
    check_command => '/usr/lib/nagios/plugins/check_procs -c 1:20 -u cinder -a bin/cinder-volume';
  }

  package {['qemu-utils', 'open-iscsi']:
    ensure => installed,
  }

  cron { 'cinder-volume-usage-audit':
    ensure  => absent,
    command => '/usr/bin/cinder-volume-usage-audit >/dev/null 2>&1',
    user    => 'root',
    minute  => 5,
    require => Package['cinder-volume'],
  }

}
