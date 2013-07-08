class cinder::api inherits cinder {

  package {'cinder-api':
    ensure => installed,
  }

  service {'cinder-api':
    ensure    => running,
    subscribe => [ File['/etc/cinder/cinder.conf'],
                   File['/etc/cinder/api-paste.ini']],
    require   => Package['cinder-api'],
  }

  nagios::service {
    "http_cinder":
      check_command => "http_port!${port}";
  }

  nagios::nrpe::service { 'service_cinder_api':
    check_command => '/usr/lib/nagios/plugins/check_procs -c 1:20 -u cinder -a /usr/bin/cinder-api';
  }

}
