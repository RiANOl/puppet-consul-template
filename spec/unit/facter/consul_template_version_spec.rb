require "spec_helper"

describe Facter::Util::Fact do
  before { Facter.clear }
  after { Facter.clear }

  describe "consul_template_version" do

    it 'should return current consul-template version on Linux' do
      consul_template_version_output = <<-EOS
consul-template v0.19.0 (33b34b3)
      EOS
      allow(Facter.fact(:kernel)).to receive(:value).and_return("Linux")
      allow(Facter::Util::Resolution).to receive(:exec).with('consul_template --version 2> /dev/null').
        and_return(consul_template_version_output)
      expect(Facter.fact(:consul_template_version).value).to match('0.19.0')
    end

  end

end
