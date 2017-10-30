class cinder::api($service_ensure='running', $workers=1) inherits cinder {

  package {'cinder-api':
    ensure => installed,
    tag    => 'openstack',
  }

  service {'cinder-api':
    ensure    => $service_ensure,
    subscribe => [ File['/etc/cinder/cinder.conf'],
                   File['/etc/cinder/api-paste.ini']],
    require   => Package['cinder-api'],
  }

  nagios::service {
    'http_cinder':
      check_command => "http_port!${port}";
  }

  if $service_ensure == 'running' {
    $workers_real = $workers + 1
    nagios::nrpe::service { 'service_cinder_api':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${workers_real}:${workers_real} -u cinder -a bin/cinder-api";
    }
  }

  firewall { '100 cinder-api':
    dport  => $cinder::port,
    proto  => tcp,
    action => accept,
  }

}
