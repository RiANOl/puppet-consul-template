require 'spec_helper'

RSpec.shared_examples 'consul_template_watch' do |title, file_ensure, file_type, file_content, owner, group, mode, notify|
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_class('consul_template') }
  it { is_expected.to contain_file("/etc/consul-template/#{title}.ctmpl")
    .with_ensure(file_ensure)
    .send(:"with_#{file_type}", file_content)
    .with_owner(owner)
    .with_group(group)
    .with_mode(mode)
    .with_notify(notify ? 'Class[Consul_template::Run_service]' : nil)
  }
end

describe 'consul_template::watch' do
  let(:title) { 'my_watch' }

  context 'without destination' do
    it { is_expected.to compile.and_raise_error(/expects a value for parameter 'destination'/) }
  end

  context 'with source has puppet: prefix' do
    let(:params) {{
      destination: '/path/to/destination',
      source: 'puppet:///path/to/source',
    }}

    include_examples 'consul_template_watch', 'my_watch', 'file', 'source', 'puppet:///path/to/source', 'root', 'root', '0660', true

    it { is_expected.to contain_concat_fragment('consul-template/config.hcl-template-my_watch')
      .with_content(/source = "\/etc\/consul-template\/my_watch.ctmpl"/)
      .with_content(/destination = "\/path\/to\/destination"/)
      .without_content(/command/)
      .with_content(/perms = "0644"/)
    }
  end

  context 'with source has http: prefix' do
    let(:params) {{
      destination: '/path/to/destination',
      source: 'http://example.com/source',
    }}

    include_examples 'consul_template_watch', 'my_watch', 'file', 'source', 'http://example.com/source', 'root', 'root', '0660', true

    it { is_expected.to contain_concat_fragment('consul-template/config.hcl-template-my_watch')
      .with_content(/source = "\/etc\/consul-template\/my_watch.ctmpl"/)
      .with_content(/destination = "\/path\/to\/destination"/)
      .without_content(/command/)
      .with_content(/perms = "0644"/)
    }
  end

  context 'with source has file: prefix' do
    let(:params) {{
      destination: '/path/to/destination',
      source: 'file:///path/to/source',
    }}

    include_examples 'consul_template_watch', 'my_watch', 'link', 'target', 'file:///path/to/source', 'root', 'root', '0660', true

    it { is_expected.to contain_concat_fragment('consul-template/config.hcl-template-my_watch')
      .with_content(/source = "\/etc\/consul-template\/my_watch.ctmpl"/)
      .with_content(/destination = "\/path\/to\/destination"/)
      .without_content(/command/)
      .with_content(/perms = "0644"/)
    }
  end

  context 'with source has no prefix' do
    let(:params) {{
      destination: '/path/to/destination',
      source: '/path/to/source',
    }}

    include_examples 'consul_template_watch', 'my_watch', 'link', 'target', '/path/to/source', 'root', 'root', '0660', true

    it { is_expected.to contain_concat_fragment('consul-template/config.hcl-template-my_watch')
      .with_content(/source = "\/etc\/consul-template\/my_watch.ctmpl"/)
      .with_content(/destination = "\/path\/to\/destination"/)
      .without_content(/command/)
      .with_content(/perms = "0644"/)
    }
  end

  context 'with contents' do
    let(:params) {{
      destination: '/path/to/destination',
      contents: 'bar',
    }}

    include_examples 'consul_template_watch', 'my_watch', 'file', 'content', 'bar', 'root', 'root', '0660', true

    it { is_expected.to contain_concat_fragment('consul-template/config.hcl-template-my_watch')
      .with_content(/source = "\/etc\/consul-template\/my_watch.ctmpl"/)
      .with_content(/destination = "\/path\/to\/destination"/)
      .without_content(/command/)
      .with_content(/perms = "0644"/)
    }
  end

  context 'with template' do
    let(:params) {{
      destination: '/path/to/destination',
      template: 'consul_template/test.erb',
      template_vars: { 'foo' => 'bar' }
    }}

    include_examples 'consul_template_watch', 'my_watch', 'file', 'content', "bar\n", 'root', 'root', '0660', true

    it { is_expected.to contain_concat_fragment('consul-template/config.hcl-template-my_watch')
      .with_content(/source = "\/etc\/consul-template\/my_watch.ctmpl"/)
      .with_content(/destination = "\/path\/to\/destination"/)
      .without_content(/command/)
      .with_content(/perms = "0644"/)
    }
  end

  context 'with inline_template' do
    let(:params) {{
      destination: '/path/to/destination',
      inline_template: '<%= @template_vars["foo"] %>',
      template_vars: { 'foo' => 'bar' }
    }}

    include_examples 'consul_template_watch', 'my_watch', 'file', 'content', 'bar', 'root', 'root', '0660', true

    it { is_expected.to contain_concat_fragment('consul-template/config.hcl-template-my_watch')
      .with_content(/source = "\/etc\/consul-template\/my_watch.ctmpl"/)
      .with_content(/destination = "\/path\/to\/destination"/)
      .without_content(/command/)
      .with_content(/perms = "0644"/)
    }
  end

  context 'with custom parameters' do
    let(:params) {{
      destination: '/path/to/destination',
      source: 'puppet:///path/to/source',
      command: 'do something',
      perms: '0000',
    }}

    include_examples 'consul_template_watch', 'my_watch', 'file', 'source', 'puppet:///path/to/source', 'root', 'root', '0660', true

    it { is_expected.to contain_concat_fragment('consul-template/config.hcl-template-my_watch')
      .with_content(/source = "\/etc\/consul-template\/my_watch.ctmpl"/)
      .with_content(/destination = "\/path\/to\/destination"/)
      .with_content(/command = "do something"/)
      .with_content(/perms = "0000"/)
    }
  end

  context 'with custom consul_template parameters' do
    let(:pre_condition) {
      'class { "consul_template": user => "a", group => "b", config_mode => "0000", restart_on_change => false }'
    }
    let(:params) {{
      destination: '/path/to/destination',
      source: 'puppet:///path/to/source',
    }}

    include_examples 'consul_template_watch', 'my_watch', 'file', 'source', 'puppet:///path/to/source', 'a', 'b', '0000', false

    it { is_expected.to contain_concat_fragment('consul-template/config.hcl-template-my_watch')
      .with_content(/source = "\/etc\/consul-template\/my_watch.ctmpl"/)
      .with_content(/destination = "\/path\/to\/destination"/)
      .without_content(/command/)
      .with_content(/perms = "0644"/)
    }
  end

end
