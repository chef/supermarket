class CtlCommandHelper
  attr_accessor :command_name

  def initialize(command_name)
    @command_name = command_name
  end

  def must_run_as(user)
    if Process.uid != Etc.getpwnam(user).uid
      exit_failure "supermarket-ctl #{command_name} should be run as the #{user} OS user."
    end
  rescue ArgumentError
    exit_failure "supermarket-ctl requires that a #{user} OS user exist"
  end

  # Returns a string for a shell command with all the setup necessary
  # to run with the Supermarket Rails environment.
  #
  # @param [String] command - a Railsy command, e.g "bin/rails console"
  # @return [String] the command given with a preamble prepended to it to setup the Rails environment
  #
  def rails_env_cmd(command)
    preamble = 'cd /opt/supermarket/embedded/service/supermarket && '
    preamble += 'HOME=/opt/supermarket/embedded/service/supermarket '
    preamble += 'RAILS_ENV="production" '
    preamble += 'PATH=/opt/supermarket/embedded/bin:$PATH '

    preamble + command
  end

  private

  def exit_failure(msg)
    STDERR.puts msg
    exit 1
  end
end
