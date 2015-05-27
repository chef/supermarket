require 'mixlib/shellout'

# supermarket-ctl make_admin username
add_command 'make_admin', 'Make a Supermarket user an admin', 2 do

  # Find username arg
  username = ARGV[3]

  # Run rake task
  command_text = "cd /opt/supermarket/embedded/service/supermarket && sudo RAILS_ENV=\"production\" env PATH=/opt/supermarket/embedded/bin bin/rake user:make_admin user=\"#{username}\""

  # Return output to user
  shell_out = Mixlib::ShellOut.new(command_text)
  shell_out.run_command
  $stdout.puts shell_out.stdout
  $stderr.puts shell_out.stderr
  exit shell_out.exitstatus
end
