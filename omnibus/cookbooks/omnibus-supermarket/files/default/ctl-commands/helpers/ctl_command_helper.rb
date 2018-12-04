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

  private

  def exit_failure(msg)
    STDERR.puts msg
    exit 1
  end
end
