require 'mixlib/shellout'
require 'optparse'

# give this a string with everything that should come after 'rake'
def run_a_rake_command(rake_task_and_args)
  command_text = "cd /opt/supermarket/embedded/service/supermarket && \
                  RAILS_ENV=\"production\" env PATH=/opt/supermarket/embedded/bin \
                  bin/rake #{rake_task_and_args}"

  shell_out = Mixlib::ShellOut.new(command_text)
  shell_out.run_command
  $stdout.puts shell_out.stdout
  $stderr.puts shell_out.stderr
  exit shell_out.exitstatus
end

add_command_under_category 'qm-list', 'quality-metrics', 'List the names of defined quality metrics', 2 do
  run_a_rake_command 'quality_metrics:list'
end

add_command_under_category 'qm-flip-all-admin-only', 'quality-metrics', 'Flip all quality metrics visible to only admin users', 2 do
  run_a_rake_command 'quality_metrics:flip:all_admin_only'
end

add_command_under_category 'qm-flip-all-public', 'quality-metrics', 'Flip all quality metrics visible to all users', 2 do
  run_a_rake_command 'quality_metrics:flip:all_public'
end

add_command_under_category 'qm-flip-admin-only', 'quality-metrics', 'Flip a given quality metric visible to only admin users', 2 do
  args = ARGV[3..-1]
  metric_name = args.join('\ ') # handle spaces in the metric names
  if metric_name.empty?
    puts 'ERROR: Nothing to do without a metric name. e.g. qm-flip-admin-only METRIC_NAME'
    exit 1
  end

  run_a_rake_command "quality_metrics:flip:admin_only['#{metric_name}']"
end

add_command_under_category 'qm-flip-public', 'quality-metrics', 'Flip a given quality metric visible to all users', 2 do
  args = ARGV[3..-1]
  metric_name = args.join('\ ') # handle spaces in the metric names
  if metric_name.empty?
    puts 'ERROR: Nothing to do without a metric name. e.g. qm-flip-public METRIC_NAME'
    exit 1
  end

  run_a_rake_command "quality_metrics:flip:public['#{metric_name}']"
end

add_command_under_category 'qm-run-all-the-latest', 'quality-metrics', 'Run quality metrics on the latest version of all cookbooks', 2 do
  run_a_rake_command 'quality_metrics:run:all_the_latest'
end

add_command_under_category 'qm-run-on-latest', 'quality-metrics', 'Run quality metrics on the latest version of a given cookbook', 2 do
  args = ARGV[3..-1]
  cookbook_name = args.shift
  unless cookbook_name
    puts 'ERROR: Nothing to do without a cookbook name. e.g. qm-run-on-latest COOKBOOK_NAME'
    exit 1
  end

  run_a_rake_command "quality_metrics:run:on_latest[#{cookbook_name}]"
end

add_command_under_category 'qm-run-on-version', 'quality-metrics', 'Run quality metrics on given version of a named cookbook', 2 do
  args = ARGV[3..-1]
  cookbook_name = args.shift
  cookbook_version = args.shift
  unless cookbook_name && cookbook_version
    puts 'ERROR: Nothing to do without a cookbook name and version. e.g. qm-run-on-version COOKBOOK_NAME VERSION'
    exit 1
  end

  run_a_rake_command "quality_metrics:run:on_version[#{cookbook_name},#{cookbook_version}]"
end
