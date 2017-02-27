require 'mixlib/shellout'
require 'optparse'

add_command_under_category 'qm-run-all-the-latest', 'quality-metrics', 'Run quality metrics on the latest version of all cookbooks', 2 do
  # Run rake task
  command_text = "cd /opt/supermarket/embedded/service/supermarket && RAILS_ENV=\"production\" env PATH=/opt/supermarket/embedded/bin bin/rake quality_metrics:run:all_the_latest"

  shell_out = Mixlib::ShellOut.new(command_text)
  shell_out.run_command
  $stdout.puts shell_out.stdout
  $stderr.puts shell_out.stderr
  exit shell_out.exitstatus
end

add_command_under_category 'qm-run-on-latest', 'quality-metrics', 'Run quality metrics on the latest version of a given cookbook', 2 do
  args = ARGV[3..-1]
  cookbook_name = args.shift
  unless cookbook_name
    puts "ERROR: Nothing to do without a cookbook name. e.g. qm-run-on-latest COOKBOOK_NAME"
    exit 1
  end

  # Run rake task
  command_text = "cd /opt/supermarket/embedded/service/supermarket && RAILS_ENV=\"production\" env PATH=/opt/supermarket/embedded/bin bin/rake quality_metrics:run:on_latest[#{cookbook_name}]"

  shell_out = Mixlib::ShellOut.new(command_text)
  shell_out.run_command
  $stdout.puts shell_out.stdout
  $stderr.puts shell_out.stderr
  exit shell_out.exitstatus
end

add_command_under_category 'qm-run-on-version', 'quality-metrics', 'Run quality metrics on given version of a named cookbook', 2 do
  args = ARGV[3..-1]
  cookbook_name = args.shift
  cookbook_version = args.shift
  unless cookbook_name && cookbook_version
    puts "ERROR: Nothing to do without a cookbook name and version. e.g. qm-run-on-version COOKBOOK_NAME VERSION"
    exit 1
  end

  # Run rake task
  command_text = "cd /opt/supermarket/embedded/service/supermarket && RAILS_ENV=\"production\" env PATH=/opt/supermarket/embedded/bin bin/rake quality_metrics:run:on_version[#{cookbook_name},#{cookbook_version}]"

  shell_out = Mixlib::ShellOut.new(command_text)
  shell_out.run_command
  $stdout.puts shell_out.stdout
  $stderr.puts shell_out.stderr
  exit shell_out.exitstatus
end
