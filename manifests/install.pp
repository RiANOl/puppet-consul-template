#
class consul_template::install {
  case $::consul_template::install_method {
    'url': {
      $install_path = pick($::consul_template::archive_path, '/opt/consul-template/archives')

      # only notify if we are installing a new version (work around for switching to archive module)
      if getvar('::consul_template_version') != $::consul_template::version {
        $do_notify_service = $::consul_template::notify_service
      } else {
        $do_notify_service = undef
      }

      include ::archive
      file { [
        $install_path,
        "${install_path}/consul-template-${consul_template::version}"]:
        ensure => directory,
        owner  => 'root',
        group  => 0, # 0 instead of root because OS X uses "wheel".
        mode   => '0555';
      }
      -> archive { "${install_path}/consul-template-${consul_template::version}.${consul_template::download_extension}":
        ensure       => present,
        source       => $::consul_template::real_download_url,
        proxy_server => $::consul_template::proxy_server,
        extract      => true,
        extract_path => "${install_path}/consul-template-${consul_template::version}",
        creates      => "${install_path}/consul-template-${consul_template::version}/consul-template",
      }
      -> file {
        "${install_path}/consul-template-${consul_template::version}/consul-template":
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555';
        "${consul_template::bin_dir}/consul-template":
          ensure => link,
          notify => $do_notify_service,
          target => "${install_path}/consul-template-${consul_template::version}/consul-template";
      }
    }
    'package': {
      package { $::consul_template::package_name:
        ensure => $::consul_template::package_ensure,
        notify => $::consul_template::notify_service
      }

      if $::consul_template::manage_user {
        User[$::consul_template::user] -> Package[$::consul_template::package_name]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${consul_template::install_method} is invalid")
    }
  }

  if $::consul_template::manage_user {
    user { $::consul_template::user:
      ensure => 'present',
      system => true,
    }

    if $::consul_template::manage_group {
      Group[$::consul_template::group] -> User[$::consul_template::user]
    }
  }
  if $::consul_template::manage_group {
    group { $::consul_template::group:
      ensure => 'present',
      system => true,
    }
  }
}
