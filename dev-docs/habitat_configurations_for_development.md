# Steps to get habitat services up and running in dev environment

## Prerequisites

1. Install [Docker Desktop](https://www.docker.com/get-started). Start docker before trying to start the Habitat Studio.
2. [Install](https://docs.chef.io/habitat/install_habitat/) Chef Habitat. The Habitat package installs with Chef Workstation so you may already have it on your computer.
3. [Set up](https://docs.chef.io/habitat/hab_setup/) the Habitat CLI with the command `hab cli setup`.
    - Habitat Builder Instance: No
    - Set up a default origin: Yes
    - Habitat Personal Access Token: Yes PROVIDE value as `chef`
    - Supervisor Control Gateway Secret: No

Start with `hab studio enter`

## Create supermarket user in the hab environment

`hab pkg exec core/busybox-static adduser supermarket`

## Create openssl certificates required for nginx

`hab pkg exec core/openssl openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /hab/svc/supermarket-nginx/cert.key -out /hab/svc/supermarket-nginx/cert.cert`


## default.toml changes 

1. postgresql \
    listen_addresses          = ['*']

2. redis \
    bind = [*]

3. habitat-web 

    fqdn            = 'localhost'\
    port            = 3000\
    secret_key_base =  "<appropriate value>"\
    protocol        = 'https'\
    allowed_host    = "localhost"

    [nginx]\
    force_ssl = true\
    port      = 4000\
    ssl_port  = 4000

    [fieri]
    url                  = 'http://localhost:3000/fieri/jobs'
    supermarket_endpoint =  'http://localhost:3000'

### All the chef-server configurations will also be done in this file itself

4. nginx 

    [ssl]\
    enabled         = true\
    certificate     = "cert.cert"\
    certificate_key = "cert.key"

5. habitat-sidekiq \
    secret_key_base = "<appropriate value>"

## pg_hba.conf changes 
Add this line in file `postgresq/config/pg_hba.conf` this is required for local development
since we are not making postgres listen to system ip

```
host    all             all                         0.0.0.0/0    md5
```

## use the following file for nginx/config/sites_enabled/rails in dev setup

```
server {
  listen 4000 ssl;
  server_name  localhost;
  ssl_certificate cert.cert;
  ssl_certificate_key cert.key;

  location / {
      proxy_pass http://localhost:3000/;
      proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto https;
      proxy_set_header X-Forwarded-Ssl on;
      proxy_set_header X-Forwarded-Host $http_host;
      proxy_set_header X-Forwarded-Port $http_port;
      proxy_set_header origin 'https://localhost:4000';
  }
}
```

## load services 
run script `./load_hab_services.sh` to build and load all the services from local
In case you need to unload all the running services use script `./unload_hab_services`

## Once the services are loaded, you should be able to access the application from browser
`https://localhost:4000` 



