# Steps to integrate supermarket as product in automate

## Prerequisites

1. Install [Docker Desktop](https://www.docker.com/get-started). Start docker before trying to start the Habitat Studio.
2. [Install](https://docs.chef.io/habitat/install_habitat/) Chef Habitat. The Habitat package installs with Chef Workstation so you may already have it on your computer.
3. [Set up](https://docs.chef.io/habitat/hab_setup/) the Habitat CLI with the command `hab cli setup`.
    - Habitat Builder Instance: No
    - Set up a default origin: Yes
    - Habitat Personal Access Token: Yes PROVIDE value as `chef`
    - Supervisor Control Gateway Secret: No
4. [Setup automate repo](https://github.com/chef/automate). Clone the repo on your local machine and follow the steps(https://github.com/chef/automate/blob/main/dev-docs/DEV_ENVIRONMENT.md#vagrant-setup) for setting development environment

Start with `hab studio enter`

## Create Supermarket services in automate

We have already raised a PR with most changes [here](https://github.com/chef/automate/pull/6821). Explaination of change is following.

In automate all habitat services reside under path [components](https://github.com/chef/automate/tree/main/components). 

For supermarket we have 5 habitat services working together for the application to come up - 
1. Redis
2. Postgres
2. Nginx
3. Web
4. Sidekiq

We need to write the wrapper service in automate for each one of them so that the application can be brought up. 

We have created following wrapper services in automate -> 

1. automate-supermarket-redis
2. automate-supermarket-nginx
3. automate-supermaret -> for habitat-web
4. automate-supemarket-sidekiq

We are using postgres services available by default in automate by name [automate-pg-gateway](https://github.com/chef/automate/tree/main/components/automate-postgresql)

## Make in entry in products.meta
Make an entry for supermarket product in file [products.meta](https://github.com/chef/automate/blob/main/products.meta). We have made the entry like this in products.meta file - 

```
    {
      "name": "chef-supermarket",
      "type": "product",
      "aliases": ["supermarket"],
      "dependencies": ["core","postgresql"],
      "services": [
        "chef/automate-supermarket-redis",
        "chef/automate-supermarket",
        "chef/automate-supermarket-nginx",
        "chef/automate-supermarket-sidekiq"
      ]
    }
```

## Generate gen.go
Once you are done with changes in products.meta. Come out of habitat studio with command `exit`. Change directory to components/automate-deployment and run `make generate` this will update file gen.go with an entry for supermarket-product

## Edit config.toml 
In config.toml file [here](https://github.com/chef/automate/blob/main/dev/config.toml) under section `[deployment.v1]` change products name to `chef-supermarket`

## Build services
Build all the services one by one in following order
1. build components/automate-supermarket-redis
2. build components/automate-supermarket-nginx
3. build components/automate-supermarket
4. build components/automtate-deployment
5. build components/automate-cli

## Edit build.json
Create a new file [results](https://github.com/chef/automate/tree/main/results) with name build.json using command

`curl https://packages.chef.io/manifests/dev/automate/latest.json -o results/build.json`

Add following services to the end of build.json like this : - 

```
    "chef/automate-supermarket-redis",
    "chef/automate-supermarket-nginx",
    "chef/automate-supermarket-sidekiq",
    "chef/automate-supermarket"
```

## config directory changes 
Apart from above changes for services we have also made a few changes in [`api/config` directory](https://github.com/chef/automate/tree/main/api/config) as mentioned in [documentation](https://github.com/chef/automate/blob/main/components/automate-deployment/docs/how-to-add-a-service.md) these config changes are needed to declare some configuration settings for the service like logging, default port, host etc. Also make the changes mentioned in directory `components/automate-deployment/pkg/backup/spec.go`. 

## Update builder configurations
Run command `go run ./tools/bldr-config-gen` as mentioned in setup documentation

## Start all services
Run command `start_all_services` which will try and get automate-deployment service up and all the supermarket services also along with it



