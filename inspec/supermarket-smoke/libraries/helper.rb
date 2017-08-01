def fetch_supermarket_version
  attribute('application_version', default: ENV['SUPERMARKET_VERSION'])
end

def fetch_target_host
  attribute('target_host', default: command('cat /etc/supermarket/supermarket.json | grep -Po "fqdn[\"\'\s:]+\K.*(?=[\"\']+?)"').stdout.strip)
end
