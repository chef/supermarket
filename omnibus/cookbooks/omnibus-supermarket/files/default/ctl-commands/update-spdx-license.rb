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

# give this a string with everything that should come after 'rake'
def run_a_rake_command(rake_task_and_args)
  cmd_helper = CtlCommandHelper.new('spdx-<command>')
  cmd_helper.must_run_as 'supermarket'

  command_text = cmd_helper.rails_env_cmd("bin/rake #{rake_task_and_args}")
  shell_out = Mixlib::ShellOut.new(command_text)
  shell_out.run_command
  $stdout.puts shell_out.stdout
  $stderr.puts shell_out.stderr
  exit shell_out.exitstatus
end

add_command_under_category 'spdx-all', 'spdx-license', 'update spdx license for all cookbooks', 2 do
  run_a_rake_command 'update_spdx_license:run:all_cookbooks'
end

add_command_under_category 'spdx-latest', 'spdx-license', 'update spdx license for given version of a named cookbook', 2 do
  args = ARGV[2..-1]
  cookbook_name = args.shift
  unless cookbook_name
    puts 'ERROR: Nothing to do without a cookbook name. e.g. spdx-on-latest COOKBOOK_NAME'
    exit 1
  end

  run_a_rake_command "update_spdx_license:run:on_latest[#{cookbook_name}]"
end

add_command_under_category 'spdx-on-version', 'spdx-license', 'update spdx license for latest version of a named cookbook', 2 do
  args = ARGV[3..-1]
  cookbook_name = args.shift
  cookbook_version = args.shift
  unless cookbook_name
    puts 'ERROR: Nothing to do without a cookbook name. e.g. spdx-on-version COOKBOOK_NAME'
    exit 1
  end

  run_a_rake_command "update_spdx_license:run:on_version[#{cookbook_name},#{cookbook_version}]"
end

