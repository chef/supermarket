listen "{{cfg.web.listen_if}}:{{cfg.web.listen_port}}"

# What the timeout for killing busy workers is, in seconds
timeout {{cfg.web.timeout}}

# Whether the app should be pre-loaded
preload_app true

# How many worker processes
worker_processes {{cfg.web.worker_processes}}

# Run forked children as specified user/group
user "{{pkg.svc_user}}", "{{pkg.svc_group}}"

# Where to drop a pidfile
pid '{{pkg.svc_var_path}}/unicorn.pid'

before_fork do |_server, _worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |_server, _worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end

# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end
