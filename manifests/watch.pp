#
define consul_template::watch (
  String $destination,
  Optional[String] $source          = undef,
  Optional[String] $contents        = undef,
  Optional[String] $template        = undef,
  Optional[String] $inline_template = undef,
  Optional[String] $command         = undef,
  Hash $template_vars               = {},
  Pattern[/^[0-9]{4}$/] $perms      = '0644',
) {
  include ::consul_template

  if count([$source, $contents, $template, $inline_template]) != 1 {
    err('Specify only one of source, contents, template or inline_template parameter for consul_template::watch')
  }

  $real_source = "${::consul_template::config_dir}/${title}.ctmpl"

  if $source != undef {
    if $source =~ /^(puppet|http):/ {
      $file_ensure = 'file'
      $file_type = 'source'
    } else {
      $file_ensure = 'link'
      $file_type = 'target'
    }
    $file_content = $source
  } else {
    $file_ensure = 'file'
    $file_type = 'content'
    if $contents != undef {
      $file_content = $contents
    } elsif $template != undef {
      $file_content = template($template)
    } else {
      $file_content = inline_template($inline_template)
    }
  }

  $files = {
    $real_source => {
      ensure         => $file_ensure,
      "${file_type}" => $file_content,
      owner          => $::consul_template::user,
      group          => $::consul_template::group,
      mode           => $::consul_template::config_mode,
      notify         => $::consul_template::notify_service,
    }
  }

  create_resources(file, $files)

  $config_hash = {
    template => delete_undef_values({
      source      => $real_source,
      destination => $destination,
      command     => $command,
      perms       => $perms,
    })
  }

  concat::fragment { "consul-template/config.hcl-template-${title}":
    target  => 'consul-template/config.hcl',
    content => consul_template::hcl($config_hash, $::consul_template::config_indent),
  }
}
