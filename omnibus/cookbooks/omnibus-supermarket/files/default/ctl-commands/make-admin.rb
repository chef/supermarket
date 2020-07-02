require 'mixlib/shellout'
# due to how things are being exec'ed, the CWD will be all wrong,
# so we want to use the full path when loaded from omnibus-ctl,
# but we need the local relative path for it to work with rspec
begin
  require 'helpers/ctl_command_helper'
rescue LoadError
  require '/opt/supermarket/embedded/service/omnibus-ctl/helpers/ctl_command_helper'
end

# supermarket-ctl make_admin username
add_command_under_category 'make-admin', 'user-management', 'Make a Supermarket user an admin', 2 do
  cmd_helper = CtlCommandHelper.new('make-admin')
  cmd_helper.must_run_as 'supermarket'

  # Find username arg
  username = ARGV[3]

  # Run rake task
  cmd = cmd_helper.rails_env_cmd("bin/rake user:make_admin user='#{username}'")

  # Return output to user
  shell_out = Mixlib::ShellOut.new(cmd)
  shell_out.run_command
  $stdout.puts shell_out.stdout
  $stderr.puts shell_out.stderr
  exit shell_out.exitstatus
end
