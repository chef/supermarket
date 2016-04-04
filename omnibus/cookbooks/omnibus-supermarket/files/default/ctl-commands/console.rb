add_command 'console', 'Enter the rails console for Supermarket', 1 do
  cmd = "cd /opt/supermarket/embedded/service/supermarket && sudo -u supermarket env PATH=/opt/supermarket/embedded/bin bin/rails console production"
  exec cmd
  true
end
