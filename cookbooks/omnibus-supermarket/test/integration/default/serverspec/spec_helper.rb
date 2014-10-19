require 'json'
require 'serverspec'

set :backend, :exec
set_property JSON.parse(open('/etc/supermarket/supermarket-running.json').read)
