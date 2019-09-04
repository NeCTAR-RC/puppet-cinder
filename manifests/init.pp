# Base cinder class - installs config files
class cinder(
  $listen='0.0.0.0',
  $port='8776',
  $availability_zone,
  $glance_api_servers,
  $transport_url,
  $rabbit_ssl=true,
  $rabbit_ha=true,
  $keystone_user,
  $keystone_password,
  $memcache_servers='localhost:11211',
  $swift_url=undef,
  $volume_config=undef,
  $volume_host=undef,
  $icehouse_compat=false,
  $ensure_az=false,
  $az_as_volume_type=false,
  $public_endpoint=undef,
  $enabled_backends=undef,
  $log_file=undef,
  $scheduler_default_filters=['AvailabilityZoneFilter','CapacityFilter','CapabilitiesFilter','DriverFilter'],
)
{

  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $openstack_version = hiera('openstack_version')
  $api_workers = hiera('cinder::api::workers', 1)
  $database_connection = hiera('cinder::db::database_connection')

  package {'cinder-common':
    ensure => installed,
    tag    => 'openstack',
  }

  file { '/etc/cinder/cinder.conf':
    ensure  => present,
    owner   => cinder,
    group   => cinder,
    mode    => '0600',
    content => template("cinder/${openstack_version}/cinder.conf.erb"),
    require => Package['cinder-common'],
    notify  => Service[$::apache::service::service_name],
  }

  file { '/etc/cinder/api-paste.ini':
    ensure  => present,
    owner   => cinder,
    group   => cinder,
    mode    => '0600',
    content => template("cinder/${openstack_version}/api-paste.ini.erb"),
    require => Package['cinder-common'],
    notify  => Service[$::apache::service::service_name],
  }

  file { '/etc/cinder/policy.yaml':
    ensure  => present,
    owner   => cinder,
    group   => cinder,
    mode    => '0644',
    source  => "puppet:///modules/cinder/${openstack_version}/policy.yaml",
    require => Package['cinder-common'],
  }
  file { '/etc/cinder/policy.json':
    ensure  => absent,
  }

  file { '/etc/cinder/resource_filters.json':
    ensure  => present,
    owner   => cinder,
    group   => cinder,
    mode    => '0644',
    source  => "puppet:///modules/cinder/${openstack_version}/resource_filters.json",
    require => Package['cinder-common'],
    notify  => Service[$::apache::service::service_name],
  }

  include ::memcached::python
}
