# consul_template_version.rb

Facter.add(:consul_template_version) do
  confine :kernel => 'Linux'
  setcode do
    original_path = ENV['PATH']
    path = ENV.fetch('PATH') { '/usr/local/bin:/usr/bin/:/bin' }
    ENV['PATH'] = '/usr/local/bin:' + path
    begin
      Facter::Util::Resolution.exec('consul_template --version 2> /dev/null').lines.first.split[1].tr('v','')
    rescue
      nil
    ensure
      ENV['PATH'] = original_path
    end
  end
end
