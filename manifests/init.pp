class cinder($listen='0.0.0.0',
             $port='8776',
             $db_host,
             $db_user='cinder',
             $db_pass,
             $rabbit_hosts,
             $rabbit_user='cinder',
             $rabbit_pass,
             $rabbit_ssl=true,
             $rabbit_ha=true,
             $rabbit_virtual_host='/',
             $keystone_user,
             $keystone_password,
             $memcache_servers='localhost:11211',
             $volume_config,
)
{

  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')

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

  realize Package['python-mysqldb']
  
}
