##
# Unicorn config
# Managed by Habitat - Local Changes will be Nuked from Orbit (just to be sure)
##

# Where to drop a pidfile
pid '{{pkg.svc_var_path}}/unicorn.pid'

{{~#with cfg.unicorn}}
# What ports/sockets to listen on, and what options for them.
listen "{{listen_ip}}:{{listen_port}}"

{{~#if working_directory}}
working_directory '{{working_directory}}'
{{~/if}}

# What the timeout for killing busy workers is, in seconds
timeout {{worker_timeout}}

# Whether the app should be pre-loaded
preload_app {{preload_app}}

# How many worker processes
worker_processes {{worker_processes}}

{{~#if unicorn_command_line}}
Unicorn::HttpServer::START_CTX[0] = "{{unicorn_command_line}}"
{{~/if}}

# Run forked children as specified user/group
user "{{forked_user}}", "{{forked_group}}"

{{~#if before_exec}}
# What to do right before exec()-ing the new unicorn binary
before_exec do |server|
  {{before_exec}}
end
{{~/if}}

{{~#if before_fork}}
# What to do before we fork a worker
before_fork do |server, worker|
  {{before_fork}}
end
{{~/if}}

{{~#if after_fork}}
# What to do after we fork a worker
after_fork do |server, worker|
  {{after_fork}}
end
{{~/if}}

{{~#if stderr_path}}
# Where stderr gets logged
stderr_path '{{stderr_path}}'
{{~/if}}

{{~#if stdout_path}}
# Where stdout gets logged
stdout_path '{{stdout_path}}'
{{~/if}}

{{~#if copy_on_write}}
# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end
{{~/if}}

{{~#if enable_stats}}
# https://newrelic.com/docs/ruby/ruby-gc-instrumentation
if GC.respond_to?(:enable_stats)
  GC.enable_stats
end
if defined?(GC::Profiler) and GC::Profiler.respond_to?(:enable)
  GC::Profiler.enable
end
{{~/if}}
{{~/with}}
