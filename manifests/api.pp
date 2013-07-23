class cinder::api($service_ensure='running') inherits cinder {

  package {'cinder-api':
    ensure => installed,
  }

  service {'cinder-api':
    ensure    => $service_ensure,
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

  firewall { '100 cinder-api':
    dport  => $port,
    proto  => tcp,
    action => accept,
  }

  define worker() {
    file { "/etc/cinder/cinder-api-${name}.conf":
      ensure  => present,
      owner   => cinder,
      group   => cinder,
      mode    => '0600',
      content => "[DEFAULT]\nosapi_volume_listen_port = ${name}",
      notify  => Service["cinder-api-${name}"],
    }

    file {"/etc/init/cinder-api-${name}.conf":
      content => template('cinder/api-init.conf.erb'),
    }

    service {"cinder-api-${name}":
      ensure    => running,
      provider  => upstart,
      subscribe => [ File['/etc/cinder/cinder.conf'],
                     File['/etc/cinder/api-paste.ini']],
      require   => File["/etc/init/cinder-api-${name}.conf"],
    }
  }


}
