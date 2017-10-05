# puppet-consul-template

## What This Module Affects

* Installs the consul-template daemon (via url or package)
  * If installing from zip, you *must* ensure the unzip utility is available.
* Optionally installs a user (w/ or w/o group) to run it under.
* Installs a configuration file (Generally, it would be /etc/consul-template/config.hcl).
* Manages the consul-template service via upstart, sysv, or systemd.

## Usage

To set up consul-template with official pre-compiled binary:
```puppet
class { consul_template:
  config_hash => {
    consul => {
      address => "127.0.0.1:8500",
      token   => "abcd1234",
    }
  }.
}
```

Disable install and service management:
```puppet
class { consul_template:
  install_method => 'none',
  init_style     => 'unmanaged',
  manage_service => false,
  config_hash => {
    consul => {
      address => "127.0.0.1:8500",
      token   => "abcd1234",
    }
  }.
}
```

## Watch files
Watch Consul key/value with ctmpl file:
```puppet
consul_template::watch { 'foo':
  destination => '/etc/foo/config.json',
  source      => '/path/to/config.json.ctmpl',
  command     => 'service foo restart',
}
```

Or inline template:
```puppet
consul_template::watch { 'foo':
  destination => '/etc/foo/config.json',
  contents    => '{{ keyOrDefault "foo/bar" }}',
  command     => 'service foo restart',
}
```

Or ERB template:
```puppet
consul_template::watch { 'foo':
  destination   => '/etc/foo/config.json',
  template      => '/path/to/config.json.ctmpl.erb',
  command       => 'service foo restart',
  template_vars => {
    foo => 'bar',
  },
}
```

Or inline ERB template:
```puppet
consul_template::watch { 'foo':
  destination     => '/etc/foo/config.json',
  inline_template => '{{ keyOrDefault "foo/<%= @template_vars["foo"] %>" }}',
  command         => 'service foo restart',
  template_vars   => {
    foo => 'bar',
  },
}
```

## Limitations
Depends on ruby > 1.9.3.

## Development
Open an [issue](https://github.com/RiANOl/puppet-consul-template/issues) or
[fork](https://github.com/RiANOl/puppet-consul-template/fork) and open a
[Pull Request](https://github.com/RiANOl/puppet-consul-template/pulls).
