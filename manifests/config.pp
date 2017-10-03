#
class consul_template::config {

  if $::consul_template::init_style != 'unmanaged' {

    case $::consul_template::init_style {
      'upstart': {
        file { '/etc/init/consul-template.conf':
          mode    => '0444',
          owner   => 'root',
          group   => 'root',
          content => template('consul_template/consul-template.upstart.erb'),
        }
        file { '/etc/init.d/consul-template':
          ensure => link,
          target => '/lib/init/upstart-job',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
        }
      }
      'systemd': {
        file { '/etc/systemd/system/consul-template.service':
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template('consul_template/consul-template.systemd.erb'),
        }
        ~> exec { 'consul-template-systemd-reload':
          command     => 'systemctl daemon-reload',
          path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
          refreshonly => true,
        }
      }
      'init','redhat': {
        file { '/etc/init.d/consul-template':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('consul_template/consul-template.init.erb')
        }
      }
      'debian': {
        file { '/etc/init.d/consul-template':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('consul_template/consul-template.debian.erb')
        }
      }
      'sles': {
        file { '/etc/init.d/consul-template':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('consul_template/consul-template.sles.erb')
        }
      }
      'launchd': {
        file { '/Library/LaunchDaemons/com.hashicorp.consul-template.daemon.plist':
          mode    => '0644',
          owner   => 'root',
          group   => 'wheel',
          content => template('consul_template/consul-template.launchd.erb')
        }
      }
      'freebsd': {
        file { '/etc/rc.conf.d/consul-template':
          mode    => '0444',
          owner   => 'root',
          group   => 'wheel',
          content => template('consul_template/consul-template.freebsd-rcconf.erb')
        }
        file { '/usr/local/etc/rc.d/consul-template':
          mode    => '0555',
          owner   => 'root',
          group   => 'wheel',
          content => template('consul_template/consul-template.freebsd.erb')
        }
      }
      default: {
        fail("Unsupported init style: ${consul_template::init_style}")
      }
    }
  }

  file { $::consul_template::config_dir:
    ensure  => 'directory',
    owner   => $::consul_template::user,
    group   => $::consul_template::group,
    purge   => $::consul_template::purge_config_dir,
    recurse => $::consul_template::purge_config_dir,
  }
  -> concat { 'consul-template/config.hcl':
    ensure => present,
    path   => "${consul_template::config_dir}/config.hcl",
    owner  => $::consul_template::user,
    group  => $::consul_template::group,
    mode   => $::consul_template::config_mode,
  }

  concat::fragment { 'consul-template/config.hcl':
    target  => 'consul-template/config.hcl',
    content => consul_template::hcl($::consul_template::real_config_hash, $::consul_template::config_indent),
    order   => '00',
  }

}
