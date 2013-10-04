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

  nagios::nrpe::service { 'service_cinder_volume':
    check_command => '/usr/lib/nagios/plugins/check_procs -c 1:20 -u cinder -a /usr/bin/cinder-volume';
  }

  package {['qemu-utils', 'open-iscsi']:
    ensure => installed,
  }

  cron { 'cinder-volume-usage-audit':
    ensure  => present,
    command => '/usr/bin/cinder-volume-usage-audit >/dev/null 2>&1',
    user    => 'root',
    minute  => 5,
    require => Package['cinder-volume'],
  }

}
