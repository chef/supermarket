listen "{{cfg.app.listen_on}}:{{cfg.app.port}}"


# What the timeout for killing busy workers is, in seconds
timeout {{cfg.unicorn.timeout}}

# Whether the app should be pre-loaded
preload_app true

# How many worker processes
worker_processes {{cfg.unicorn.worker_processes}}


# Run forked children as specified user/group
user "{{pkg.svc_user}}", "{{pkg.svc_group}}"


# Where to drop a pidfile
pid '{{pkg.svc_var_path}}/unicorn.pid'

# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end
