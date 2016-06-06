require 'mixlib/shellout'
require 'optparse'
# due to how things are being exec'ed, the CWD will be all wrong,
# so we want to use the full path when loaded from omnibus-ctl,
# but we need the local relative path for it to work with rspec
begin
  require 'helpers/ctl_command_helper'
rescue LoadError
  require '/opt/supermarket/embedded/service/omnibus-ctl/helpers/ctl_command_helper'
end

add_command 'test', 'Run the Supermarket installation test suite', 2 do
  cmd_helper = CtlCommandHelper.new('test')
  cmd_helper.must_run_as 'supermarket'

  options = {}
  OptionParser.new do |opts|
    opts.on '-J', '--junit-xml PATH' do |junit_xml|
      options[:junit_xml] = junit_xml
    end
  end.parse!

  command_text = "/opt/supermarket/embedded/bin/rspec" \
    " -I /opt/supermarket/embedded/cookbooks/omnibus-supermarket/test/integration/default/serverspec" \
    " --format documentation" \
    " --color"

  if options[:junit_xml]
    command_text += " --require yarjuf" \
      " --format JUnit" \
      " --out #{options[:junit_xml]}"
  end

  command_text += ' /opt/supermarket/embedded/cookbooks/omnibus-supermarket/test/integration/default/serverspec/**/*_spec.rb' \

  shell_out = Mixlib::ShellOut.new(command_text)
  shell_out.run_command
  $stdout.puts shell_out.stdout
  $stderr.puts shell_out.stderr
  exit shell_out.exitstatus
end
