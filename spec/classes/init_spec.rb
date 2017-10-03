require 'spec_helper'

describe 'consul_template' do

  context 'on an unsupported arch' do
    let(:facts) {{
      architecture: 'foo',
    }}
    it { is_expected.to compile.and_raise_error(/Unsupported kernel architecture:/) }
  end

  context 'on Ubuntu 8.04' do
    let(:facts) {{
      operatingsystem: 'Ubuntu',
      operatingsystemrelease: '8.04',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('debian') }
  end

  context 'on Ubuntu 14.04' do
    let(:facts) {{
      operatingsystem: 'Ubuntu',
      operatingsystemrelease: '14.04',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('upstart') }
  end

  context 'on Ubuntu 16.04' do
    let(:facts) {{
      operatingsystem: 'Ubuntu',
      operatingsystemrelease: '16.04',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('systemd') }
  end

  context 'on Fedora 11' do
    let(:facts) {{
      osfamily: 'RedHat',
      operatingsystem: 'Fedora',
      operatingsystemrelease: '11',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('init') }
  end

  context 'on Fedora 20' do
    let(:facts) {{
      osfamily: 'RedHat',
      operatingsystem: 'Fedora',
      operatingsystemrelease: '20',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('systemd') }
  end

  context 'on an Amazon based OS' do
    let(:facts) {{
      osfamily:  'RedHat',
      operatingsystem: 'Amazon',
      operatingsystemrelease: '3.10.34-37.137.amzn1.x86_64',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('redhat') }
  end

  context 'on a Redhat 6 based OS' do
    let(:facts) {{
      osfamily: 'RedHat',
      operatingsystem: 'CentOS',
      operatingsystemrelease: '6.5',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('redhat') }
  end

  context 'on a Redhat 7 based OS' do
    let(:facts) {{
      osfamily: 'RedHat',
      operatingsystem: 'CentOS',
      operatingsystemrelease: '7.0',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('systemd') }
  end

  context 'on Debian 7.1' do
    let(:facts) {{
      operatingsystem: 'Debian',
      operatingsystemrelease: '7.1',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('debian') }
  end

  context 'on Debian 8.0' do
    let(:facts) {{
      operatingsystem: 'Debian',
      operatingsystemrelease: '8.0',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('systemd') }
  end

  context 'on an Archlinux based OS' do
    let(:facts) {{
      operatingsystem: 'Archlinux',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('systemd') }
  end

  context 'on openSUSE' do
    let(:facts) {{
      :operatingsystem => 'OpenSuSE',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('systemd') }
  end

  context 'on SLED' do
    let(:facts) {{
      operatingsystem: 'SLED',
      operatingsystemrelease: '7.1',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('sles') }
  end

  context 'on SLES' do
    let(:facts) {{
      operatingsystem: 'SLES',
      operatingsystemrelease: '13.1',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('systemd') }
  end

  context 'on Darwin' do
    let(:facts) {{
      operatingsystem: 'Darwin',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('launchd') }
  end

  context 'on FreeBSD' do
    let(:facts) {{
      operatingsystem: 'FreeBSD',
    }}
    it { is_expected.to contain_class('consul_template').with_init_style('freebsd') }
  end

  context 'on an unsupported OS' do
    let(:facts) {{ operatingsystem: 'foo' }}
    it { is_expected.to compile.and_raise_error(/Cannot determine init_style, unsupported OS:/) }
  end

  context 'when requesting to install via a package with defaults' do
    let(:params) {{
      install_method: 'package',
    }}
    it { is_expected.to contain_package('consul-template').with_ensure('latest').that_notifies('Class[consul_template::run_service]') }
  end

  context 'when requesting to install via a custom package and version' do
    let(:params) {{
      install_method: 'package',
      package_ensure: 'specific_release',
      package_name: 'custom_consul_package',
    }}
    it { is_expected.to contain_package('custom_consul_package').with_ensure('specific_release').that_notifies('Class[consul_template::run_service]') }
  end

  context 'when installing via URL by default' do
    it { is_expected.to contain_archive('/opt/consul-template/archives/consul-template-0.19.3.zip').with_source('https://releases.hashicorp.com/consul-template/0.19.3/consul-template_0.19.3_linux_amd64.zip') }
    it { is_expected.to contain_file('/opt/consul-template/archives').with_ensure('directory') }
    it { is_expected.to contain_file('/opt/consul-template/archives/consul-template-0.19.3').with_ensure('directory') }
    it { is_expected.to contain_file('/usr/local/bin/consul-template').that_notifies('Class[consul_template::run_service]') }
  end

  context 'when installing via URL with a special archive_path' do
    let(:params) {{
      archive_path: '/usr/share/puppet-archive',
    }}
    it { is_expected.to contain_archive('/usr/share/puppet-archive/consul-template-0.19.3.zip').with_source('https://releases.hashicorp.com/consul-template/0.19.3/consul-template_0.19.3_linux_amd64.zip') }
    it { is_expected.to contain_file('/usr/share/puppet-archive').with_ensure('directory') }
    it { is_expected.to contain_file('/usr/share/puppet-archive/consul-template-0.19.3').with_ensure('directory') }
    it { is_expected.to contain_file('/usr/local/bin/consul-template').that_notifies('Class[consul_template::run_service]') }
  end

  context 'when installing by archive via URL and current version is already installed' do
    let(:facts) {{
      consul_template_version: '0.19.3',
    }}
    it { is_expected.to contain_archive('/opt/consul-template/archives/consul-template-0.19.3.zip').with_source('https://releases.hashicorp.com/consul-template/0.19.3/consul-template_0.19.3_linux_amd64.zip') }
    it { is_expected.to contain_file('/usr/local/bin/consul-template') }
    it { is_expected.not_to contain_notify(['Class[consul_template::run_service]']) }
  end

  context 'when installing via URL by with a special version' do
    let(:params) {{
      version: '0.19.4',
    }}
    it { is_expected.to contain_archive('/opt/consul-template/archives/consul-template-0.19.4.zip').with_source('https://releases.hashicorp.com/consul-template/0.19.4/consul-template_0.19.4_linux_amd64.zip') }
    it { is_expected.to contain_file('/usr/local/bin/consul-template').that_notifies('Class[consul_template::run_service]') }
  end

  context 'when installing via URL by with a custom url' do
    let(:params) {{
      download_url: 'http://myurl',
    }}
    it { is_expected.to contain_archive('/opt/consul-template/archives/consul-template-0.19.3.zip').with_source('http://myurl') }
    it { is_expected.to contain_file('/usr/local/bin/consul-template').that_notifies('Class[consul_template::run_service]') }
  end

  context 'when requesting to not to install' do
    let(:params) {{
      install_method: 'none',
    }}
    it { is_expected.not_to contain_package('consul_template') }
    it { is_expected.not_to contain_archive('/opt/consul-template/archives/consul-0.19.3.zip') }
  end

  context 'when asked to manage user' do
    let(:params) {{
      manage_user: true,
      user: 'foo',
    }}
    it { is_expected.to contain_user('foo') }
  end

  context 'when asked to manage group' do
    let(:params) {{
      manage_group: true,
      group: 'foo',
    }}
    it { is_expected.to contain_group('foo') }
  end

  context 'when asked not to manage the init system' do
    let(:params) {{
      init_style: 'unmanaged',
    }}
    it { is_expected.not_to contain_file('/etc/init.d/consul-template') }
    it { is_expected.not_to contain_file('/etc/systemd/system/consul-template.service') }
    it { is_expected.not_to contain_file('/Library/LaunchDaemons/com.hashicorp.consul-template.daemon.plist') }
    it { is_expected.not_to contain_file('/usr/local/etc/rc.d/consul-template') }
  end

  context 'when using upstart init style' do
    let(:params) {{
      init_style: 'upstart',
    }}
    it { is_expected.to contain_file('/etc/init/consul-template.conf').with_content(/Consul Template \(Upstart unit\)/) }
    it { is_expected.to contain_file('/etc/init.d/consul-template').with_ensure('link').with_target('/lib/init/upstart-job') }
  end

  context 'when using systemd init style' do
    let(:params) {{
      init_style: 'systemd',
    }}
    it { is_expected.to contain_file('/etc/systemd/system/consul-template.service').with_content(/Description=Consul Template/) }
    it { is_expected.to contain_exec('consul-template-systemd-reload').with_command('systemctl daemon-reload').with_refreshonly(true) }
  end

  context 'when using init init style' do
    let(:params) {{
      init_style: 'init',
    }}
    it { is_expected.to contain_file('/etc/init.d/consul-template').with_content(/\. \/etc\/init\.d\/functions/) }
  end

  context 'when using redhat init style' do
    let(:params) {{
      init_style: 'redhat',
    }}
    it { is_expected.to contain_file('/etc/init.d/consul-template').with_content(/\. \/etc\/init\.d\/functions/) }
  end

  context 'when using debian init style' do
    let(:params) {{
      init_style: 'debian',
    }}
    it { is_expected.to contain_file('/etc/init.d/consul-template').with_content(/\. \/lib\/lsb\/init-functions/) }
  end

  context 'when using sles init style' do
    let(:params) {{
      init_style: 'sles',
    }}
    it { is_expected.to contain_file('/etc/init.d/consul-template').with_content(/\. \/etc\/rc.status/) }
  end

  context 'when using launchd init style' do
    let(:params) {{
      init_style: 'launchd',
    }}
    it { is_expected.to contain_file('/Library/LaunchDaemons/com.hashicorp.consul-template.daemon.plist').with_content(/com\.hashicorp\.consul-template/) }
  end

  context 'when using freebsd init style' do
    let(:params) {{
      init_style: 'freebsd',
    }}
    it { is_expected.to contain_file('/etc/rc.conf.d/consul-template').with_content(/consul_template_enable=/) }
    it { is_expected.to contain_file('/usr/local/etc/rc.d/consul-template').with_content(/\. \/etc\/rc.subr/) }
  end

  context 'when using unsupported init style' do
    let(:params) {{
      init_style: 'foo',
    }}
    it { is_expected.to compile.and_raise_error(/Unsupported init style:/) }
  end

  context 'when configuring with default config dir, user, group and mode' do
    it { is_expected.to contain_file('/etc/consul-template').with_ensure('directory').with_owner('root').with_group('root') }
    it { is_expected.to contain_concat('consul-template/config.hcl').with_path('/etc/consul-template/config.hcl').with_owner('root').with_group('root').with_mode('0660') }
  end

  context 'when configuring with custom config dir, user, group and mode' do
    let(:params) {{
      config_dir: '/usr/local/etc/consul-template',
      user: 'foo',
      group: 'bar',
      config_mode: '0666',
    }}
    it { is_expected.to contain_file('/usr/local/etc/consul-template').with_owner('foo').with_group('bar') }
    it { is_expected.to contain_concat('consul-template/config.hcl').with_path('/usr/local/etc/consul-template/config.hcl').with_owner('foo').with_group('bar').with_mode('0666') }
  end

  context 'when asked not to purge config dir' do
    let(:params) {{
      purge_config_dir: false,
    }}
    it { is_expected.to contain_file('/etc/consul-template').with_purge(false).with_recurse(false) }
  end

  context 'when config_defaults is used to provide additional config and is overridden by config_hash' do
    let(:params) {{
      config_defaults: {
        'consul' => {
          'address' => '127.0.0.1:8500',
          'token'   => 'foo',
        },
      },
      config_hash: {
        'consul' => {
          'token'   => 'bar',
        },
      }
    }}
    it { is_expected.to contain_concat_fragment('consul-template/config.hcl').with_content(/address = "127\.0\.0\.1:8500"/) }
    it { is_expected.to contain_concat_fragment('consul-template/config.hcl').with_content(/token = "bar"/) }
  end

  context 'when asked not to restart on change' do
    let(:params) {{
      restart_on_change: false
    }}
    it { is_expected.not_to contain_class('consul_template::config').that_notifies('Class[consul_template::run_service]') }
  end

  context 'when watches provided' do
    let(:params) {{
      watches: {
        'watch1' => {
          'destination' => 'destination1',
          'source'      => 'source1',
        },
        'watch2' => {
          'destination' => 'destination2',
          'source'      => 'source2',
        }
      }
    }}
    it { is_expected.to contain_consul_template__watch('watch1').with_destination('destination1').with_source('source1') }
    it { is_expected.to contain_consul_template__watch('watch2').with_destination('destination2').with_source('source2') }
  end
end
