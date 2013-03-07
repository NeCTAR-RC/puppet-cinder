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
    'http_openstack_18776':
      check_command => 'http_port!18776';
  }

  nagios::nrpe::service { 'service_cinder_api':
    check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u cinder -a /usr/bin/cinder-api';
  }

}

class cinder::api::load-balanced($upstream) inherits cinder::api {

  include nginx

  nginx::proxy { 'cinder':
    port         => 8776,
    ssl          => true,
    upstreams    => $upstream,
    nagios_check => false,
  }

  nagios::service {
    'http_openstack_8776':
      check_command => 'https_port!8776',
      servicegroups => 'openstack-endpoints';
  }

}
