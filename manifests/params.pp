#
class consul_template::params {
  $archive_path       = '/opt/consul-template/archives'
  $bin_dir            = '/usr/local/bin'
  $config_defaults    = {}
  $config_hash        = {}
  $config_indent      = 4
  $config_mode        = '0660'
  $download_extension = 'zip'
  $download_url       = undef
  $download_url_base  = 'https://releases.hashicorp.com/consul-template/'
  $extra_options      = ''
  $group              = 'root'
  $install_method     = 'url'
  $log_file           = '/var/log/consul-template'
  $manage_group       = false
  $manage_service     = true
  $manage_user        = false
  $package_ensure     = 'latest'
  $package_name       = 'consul-template'
  $proxy_server       = undef
  $purge_config_dir   = true
  $restart_on_change  = true
  $service_enable     = true
  $service_ensure     = 'running'
  $user               = 'root'
  $version            = '0.19.3'
  $watches            = {}

  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    /^arm.*/:          { $arch = 'arm'   }
    default:           {
      fail("Unsupported kernel architecture: ${::architecture}")
    }
  }

  if $::operatingsystem == 'FreeBSD' {
    $config_dir = '/usr/local/etc/consul-template'
  } else {
    $config_dir = '/etc/consul-template'
  }

  $os = downcase($::kernel)

  if $::operatingsystem == 'Ubuntu' {
    if versioncmp($::operatingsystemrelease, '8.04') < 1 {
      $init_style = 'debian'
    } elsif versioncmp($::operatingsystemrelease, '15.04') < 0 {
      $init_style = 'upstart'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::osfamily == 'RedHat' {
    case $::operatingsystem {
      'Fedora': {
        if versioncmp($::operatingsystemrelease, '12') < 0 {
          $init_style = 'init'
        } else {
          $init_style = 'systemd'
        }
      }
      'Amazon': {
          $init_style = 'redhat'
      }
      default: {
        if versioncmp($::operatingsystemrelease, '7.0') < 0 {
          $init_style = 'redhat'
        } else {
          $init_style  = 'systemd'
        }
      }
    }
  } elsif $::operatingsystem == 'Debian' {
    if versioncmp($::operatingsystemrelease, '8.0') < 0 {
      $init_style = 'debian'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Archlinux' {
    $init_style = 'systemd'
  } elsif $::operatingsystem == 'OpenSuSE' {
    $init_style = 'systemd'
  } elsif $::operatingsystem =~ /SLE[SD]/ {
    if versioncmp($::operatingsystemrelease, '12.0') < 0 {
      $init_style = 'sles'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Darwin' {
    $init_style = 'launchd'
  } elsif $::operatingsystem == 'FreeBSD' {
    $init_style = 'freebsd'
  } else {
    fail("Cannot determine init_style, unsupported OS: ${::operatingsystem}")
  }
}
