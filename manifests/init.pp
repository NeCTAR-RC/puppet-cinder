# Base cinder class - installs config files
class cinder(
  $listen='0.0.0.0',
  $port='8776',
  $availability_zone,
  $glance_api_servers,
  $db_host,
  $db_name='cinder',
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
  $swift_url=undef,
  $volume_config,
  $volume_host=undef,
  $icehouse_compat=false,
  $ensure_az=false,
  $az_as_volume_type=false,
)
{

  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $openstack_version = hiera('openstack_version')
  $api_workers = hiera('cinder::api::workers', 1)

  package {'cinder-common':
    ensure => installed,
  }

  file { '/etc/cinder/cinder.conf':
    ensure  => present,
    owner   => cinder,
    group   => cinder,
    mode    => '0600',
    content => template("cinder/${openstack_version}/cinder.conf.erb"),
    require => Package['cinder-common'],
  }

  file { '/etc/cinder/api-paste.ini':
    ensure  => present,
    owner   => cinder,
    group   => cinder,
    mode    => '0600',
    content => template("cinder/${openstack_version}/api-paste.ini.erb"),
    require => Package['cinder-common'],
  }

  include mysql::python
  realize(Package['python-memcache'])
}
