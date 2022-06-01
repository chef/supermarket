#!/bin/bash -e
# Script to unload all the services from habitat studio

for service in postgresql redis sidekiq nginx; do 
	hab svc unload "chef/supermarket"-$service
done

hab svc unload "chef/supermarket"