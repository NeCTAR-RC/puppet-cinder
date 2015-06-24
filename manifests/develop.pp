# Set up a dev env for cinder
class cinder::develop($branch='nectar/juno') inherits cinder {

  include cinder::develop::api
  include cinder::develop::scheduler
  include cinder::develop::volume

  Package['cinder-common'] {
    ensure => absent,
  }

  exec {"virtualenv /opt/${cinder::openstack_version}":
    path    => '/usr/bin',
    creates => "/opt/${cinder::openstack_version}/bin/activate",
  }
  exec {'pip install -e .':
    cwd     => '/opt/cinder/',
    path    => "/opt/${cinder::openstack_version}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    creates => '/opt/juno/bin/cinder-manage',
    timeout => 3600,
  }

  exec {'pip install mysql-python':
    cwd     => '/opt/cinder/',
    path    => "/opt/${cinder::openstack_version}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    creates => "/opt/${cinder::openstack_version}/lib/python2.7/site-packages/MySQLdb",
    timeout => 3600,
  }
  exec {'pip install python-memcached':
    cwd     => '/opt/cinder/',
    path    => "/opt/${cinder::openstack_version}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    creates => "/opt/${cinder::openstack_version}/lib/python2.7/site-packages/memcache.py",
    timeout => 3600,
  }

  git::clone { 'cinder':
    git_repo        => 'https://github.com/NeCTAR-RC/cinder.git',
    projectroot     => '/opt/cinder',
    cloneddir_user  => 'cinder',
    cloneddir_group => 'cinder',
    branch          => $branch,
  }

  file {['/etc/cinder', '/var/log/cinder', '/var/lib/cinder']:
    ensure => directory,
    owner  => cinder,
    group  => cinder,
  }

  user {'cinder':
    home => '/var/lib/cinder',
  }

  file { '/etc/sudoers.d/cinder_sudoers':
    content => 'Defaults:cinder !requiretty\n\ncinder ALL = (root) NOPASSWD: /usr/local/bin/cinder-rootwrap\n',
    mode    => '0640',
  }
  file { '/etc/cinder/rootwrap.conf':
    ensure => link,
    target => '/opt/cinder/etc/cinder/rootwrap.conf',
  }

  file { '/etc/cinder/rootwrap.d':
    ensure => link,
    target => '/opt/cinder/etc/cinder/rootwrap.d',
  }
  file { '/etc/cinder/policy.json':
    ensure => link,
    target => '/opt/cinder/etc/cinder/policy.json',
  }

  file {'/usr/local/bin/cinder-manage':
    ensure => link,
    target => "/opt/${cinder::openstack_version}/bin/cinder-manage",
  }
    file {'/usr/local/bin/cinder-rootwrap':
    ensure => link,
    target => "/opt/${cinder::openstack_version}/bin/cinder-rootwrap",
  }
}

class cinder::develop::api inherits cinder::api {

  Package['cinder-api'] {
    ensure => absent,
  }

  Service['cinder-api'] {
    provider => upstart,
  }

  file {'/etc/init/cinder-api.conf':
    source => 'puppet:///modules/cinder/api-init.conf',
  }
  file {'/usr/local/bin/cinder-api':
    ensure => link,
    target => "/opt/${cinder::openstack_version}/bin/cinder-api",
  }

}

class cinder::develop::scheduler inherits cinder::scheduler {
  Package['cinder-scheduler'] {
    ensure => absent,
  }

  Service['cinder-scheduler'] {
    provider => upstart,
  }

  file {'/etc/init/cinder-scheduler.conf':
    source => 'puppet:///modules/cinder/scheduler-init.conf',
  }
  file {'/usr/local/bin/cinder-scheduler':
    ensure => link,
    target => "/opt/${cinder::openstack_version}/bin/cinder-scheduler",
  }

}

class cinder::develop::volume inherits cinder::volume {

  package {['lvm2', 'tgt']:
    ensure => installed,
  }

  Package['cinder-volume'] {
    ensure => absent,
  }

  Service['cinder-volume'] {
    provider => upstart,
  }

  file {'/etc/init/cinder-volume.conf':
    source => 'puppet:///modules/cinder/volume-init.conf',
  }
  file {'/usr/local/bin/cinder-volume':
    ensure => link,
    target => "/opt/${cinder::openstack_version}/bin/cinder-volume",
  }

  volume_group { 'cinder-volumes':
    ensure           => present,
    physical_volumes => '/dev/vdb'
  }

  firewall { '100 iscsi':
    dport  => 3260,
    proto  => tcp,
    action => accept,
  }

  file {'/etc/tgt/conf.d/cinder.conf':
    content => 'include /var/lib/cinder/volumes/*',
  }
}
