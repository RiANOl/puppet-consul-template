#
class consul_template (
  String $arch                       = $::consul_template::params::arch,
  String $archive_path               = $::consul_template::params::archive_path,
  String $bin_dir                    = $::consul_template::params::bin_dir,
  Hash $config_defaults              = $::consul_template::params::config_defaults,
  String $config_dir                 = $::consul_template::params::config_dir,
  Hash $config_hash                  = $::consul_template::params::config_hash,
  Integer $config_indent             = $::consul_template::params::config_indent,
  Pattern[/^[0-9]{4}$/] $config_mode = $::consul_template::params::config_mode,
  String $download_extension         = $::consul_template::params::download_extension,
  Optional[String] $download_url     = $::consul_template::params::download_url,
  String $download_url_base          = $::consul_template::params::download_url_base,
  String $extra_options              = $::consul_template::params::extra_options,
  String $group                      = $::consul_template::params::group,
  String $install_method             = $::consul_template::params::install_method,
  String $init_style                 = $::consul_template::params::init_style,
  String $log_file                   = $::consul_template::params::log_file,
  Boolean $manage_group              = $::consul_template::params::manage_group,
  Boolean $manage_service            = $::consul_template::params::manage_service,
  Boolean $manage_user               = $::consul_template::params::manage_user,
  String $os                         = $::consul_template::params::os,
  String $package_ensure             = $::consul_template::params::package_ensure,
  String $package_name               = $::consul_template::params::package_name,
  Optional[String] $proxy_server     = $::consul_template::params::proxy_server,
  Boolean $purge_config_dir          = $::consul_template::params::purge_config_dir,
  Boolean $restart_on_change         = $::consul_template::params::restart_on_change,
  Boolean $service_enable            = $::consul_template::params::service_enable,
  String $service_ensure             = $::consul_template::params::service_ensure,
  String $user                       = $::consul_template::params::user,
  String $version                    = $::consul_template::params::version,
  Hash[String, Hash] $watches        = $::consul_template::params::watches,
) inherits consul_template::params {

  # lint:ignore:140chars
  $real_download_url = pick($download_url, "${download_url_base}${version}/${package_name}_${version}_${os}_${arch}.${download_extension}")
  # lint:endignore

  $real_config_hash = deep_merge($config_defaults, $config_hash)

  if $watches {
    create_resources(consul_template::watch, $watches)
  }

  $notify_service = $restart_on_change ? {
    true    => Class['consul_template::run_service'],
    default => undef,
  }

  anchor {'consul_template_first': }
  -> class { 'consul_template::install': }
  -> class { 'consul_template::config':
    notify => $notify_service,
  }
  -> class { 'consul_template::run_service': }
  -> anchor {'consul_template_last': }
}
