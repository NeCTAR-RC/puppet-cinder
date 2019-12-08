#
# == Define: cinder::backend::dellemc_vmax_iscsi
#
# Setup Cinder to use the Dell EMC VMAX ISCSI Driver
# Compatible for multiple backends
#
# == Parameters
#
# [*volume_backend_name*]
#   (optional) Allows for the volume_backend_name to be separate of $name.
#   Defaults to: $name
#
# [*backend_availability_zone*]
#   (Optional) Availability zone for this volume backend.
#   If not set, the storage_availability_zone option value
#   is used as the default for all backends.
#   Defaults to $::os_service_default.
#
# [*cinder_emc_config_file*]
#   (required) File path of Dell EMC VMAX ISCSI specific configuration file.
#
# [*volume_driver*]
#   (optional) The Dell EMC VMAX ISCSI Driver
#   Defaults to cinder.volume.drivers.dell_emc.vmax.iscsi.VMAXISCSIDriver
#
# [*manage_volume_type*]
#   (Optional) Whether or not manage Cinder Volume type.
#   If set to true, a Cinder Volume type will be created
#   with volume_backend_name=$volume_backend_name key/value.
#   Defaults to false.
#
# [*extra_options*]
#   (optional) Hash of extra options to pass to the backend stanza
#   Defaults to: {}
#   Example :
#     { 'dellemc_vmax_iscsi_backend/param1' => { 'value' => value1 } }#
#
define cinder::backend::dellemc_vmax_iscsi (
  $cinder_emc_config_file,
  $volume_backend_name           = $name,
  $backend_availability_zone     = $::os_service_default,
  $extra_options                 = {},
  $volume_driver                 = 'cinder.volume.drivers.dell_emc.vmax.iscsi.VMAXISCSIDriver',
  $manage_volume_type            = false,
) {

  include cinder::deps


  cinder_config {
    "${name}/volume_backend_name":             value => $volume_backend_name;
    "${name}/backend_availability_zone":       value => $backend_availability_zone;
    "${name}/volume_driver":                   value => $volume_driver;
    "${name}/cinder_emc_config_file":          value => $cinder_emc_config_file;
  }

  if $manage_volume_type {
    cinder_type { $volume_backend_name:
      ensure     => present,
      properties => ["volume_backend_name=${volume_backend_name}"],
    }
  }

  ensure_packages( 'pywbem', {
    ensure => present,
    name   => $::cinder::params::pywbem_package_name,
    tag    => 'cinder-support-package'})

  create_resources('cinder_config', $extra_options)

}
