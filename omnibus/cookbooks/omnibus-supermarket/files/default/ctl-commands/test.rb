require 'mixlib/shellout'
require 'optparse'

add_command 'test', 'Run the Supermarket installation test suite', 2 do
  options = {}
  OptionParser.new do |opts|
    opts.on '-J', '--junit-xml PATH' do |junit_xml|
      options[:junit_xml] = junit_xml
    end
    opts.on '-v', '--verbose' do |_verbose|
      options[:verbose] = true
    end
  end.parse!

  command_text = '/opt/supermarket/embedded/bin/inspec exec'
  command_text += ' /opt/supermarket/embedded/cookbooks/omnibus-supermarket/test/integration/default/inspec'
  command_text += ' --color'
  command_text += ' --no-distinct-exit' # skipped tests are OK

  if options[:junit_xml]
    command_text += " --reporter junit:#{options[:junit_xml]}"
  end

  shell_out = Mixlib::ShellOut.new(command_text)
  shell_out.run_command
  $stdout.puts shell_out.stdout
  $stderr.puts shell_out.stderr if options[:verbose]

  exit shell_out.exitstatus
end
