require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.mock_framework = :rspec

  c.default_facts = {
    :architecture            => 'x86_64',
    :operatingsystem         => 'Ubuntu',
    :osfamily                => 'Debian',
    :operatingsystemrelease  => '14.04',
    :kernel                  => 'Linux',
    :ipaddress_lo            => '127.0.0.1',
    :consul_template_version => 'unknown',
  }

  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
