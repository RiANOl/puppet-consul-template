#
class consul_template::run_service {

  $service_name = $::consul_template::init_style ? {
    'launchd' => 'com.hashicorp.consul-template',
    default   => 'consul-template',
  }

  $service_provider = $::consul_template::init_style ? {
    'unmanaged' => undef,
    default     => $::consul_template::init_style,
  }

  if $::consul_template::manage_service == true {
    service { 'consul_template':
      ensure   => $::consul_template::service_ensure,
      name     => $service_name,
      enable   => $::consul_template::service_enable,
      provider => $service_provider,
    }
  }

}
