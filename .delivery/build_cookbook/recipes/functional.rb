#
# Cookbook Name:: build_cookbook
# Recipe:: functional
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#
# Ensure we are executing in acceptance/functional
#
# TODO: add a `delivery_stage?(stage)` helpers to delivery-sugar's DSL

if node['delivery']['change']['stage'] == 'acceptance'

  #######################################################################
  # TODO: set these things in `delivery-bus`
  #######################################################################
  delivery_bus_secrets = DeliverySugar::ChefServer.new.encrypted_data_bag_item('delivery-bus', 'secrets')

  node.set['jenkins']['master']['endpoint']  = 'http://wilson.ci.chef.co'
  node.set['jenkins']['executor']['timeout'] = 7200 # wait up to 2 hours for jobs to complete
  node.run_state[:jenkins_private_key]       = delivery_bus_secrets['jenkins_private_key']

  node.set['artifactory-pro']['endpoint']      = 'http://artifactory.chef.co:8081'
  node.run_state[:artifactory_client_username] = delivery_bus_secrets['artifactory_username']
  node.run_state[:artifactory_client_password] = delivery_bus_secrets['artifactory_password']

  #######################################################################
  # Until we have some first class `chef-acceptance` suites in place
  # we'll just execute the existing `*-test` Jenkins job. This will at
  # least install the built packages on each supported platform.
  #######################################################################
  jenkins_job "supermarket-test" do
    parameters(
      'DELIVERY_CHANGE' => delivery_change_id,
      'DELIVERY_SHA' => node['delivery']['change']['sha'],
    )
    action :build
  end

  #######################################################################
  # Once tests have passed we can safely promote the build from the
  # `unstable` to the `current` channel.
  #######################################################################
  chef_artifactory_promotion "promote Supermarket delivery change #{delivery_change_id} to current" do
    omnibus_project 'supermarket'
    delivery_change delivery_change_id
    channel :current
    comment "Promoted by #{delivery_change_id} during acceptance/functional"
    user 'dbuild'
  end

end
