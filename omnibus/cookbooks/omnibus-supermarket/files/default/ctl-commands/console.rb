# due to how things are being exec'ed, the CWD will be all wrong,
# so we want to use the full path when loaded from omnibus-ctl,
# but we need the local relative path for it to work with rspec
begin
  require 'helpers/ctl_command_helper'
rescue LoadError
  require '/opt/supermarket/embedded/service/omnibus-ctl/helpers/ctl_command_helper'
end

add_command 'console', 'Enter the rails console for Supermarket', 1 do
  cmd_helper = CtlCommandHelper.new('console')
  cmd_helper.must_run_as 'supermarket'

  cmd = 'cd /opt/supermarket/embedded/service/supermarket && env PATH=/opt/supermarket/embedded/bin:$PATH bin/rails console production'
  exec cmd
  true
end
