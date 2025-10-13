# Connect Local Supermarket with Local Chef Infra Server OC-ID

Once you have your local Supermarket and local Chef Infra Server setup you need to follow the following steps in order to connect both.

## Prereqs

- This guide assumes a Mac. Things can be modified a bit to work on Linux or Windows.
- Homebrew installed from `brew.sh`.

## Chef Infra Server Setup

- Go to `chef-server` repository directory
- Go to the dev directory:
  - `cd dev`
- Install Vagrant if you haven't already
  - `brew install vagrant`
- Spin up the vagrant instance and follow the default instructions given for chef-server setup:
  - `vagrant up`
- SSH into the vagrant machine by:
  - `vagrant ssh`
- You need to change to sudo user:
  - `sudo -i`
- Go to the specific directory as follows:
  - `cd /etc/opscode`
- You need to edit the chef-server.rb
  - `vim chef-server.rb`
- Register supermarket with oc-id in this file by appending the following configuration:

    ```ruby
    oc_id["applications"] = {
    "supermarket" => {
        "redirect_uri" => "https://localhost:4000/auth/chef_oauth2/callback"
    }
    }
    ```

- In the above configuration we are saying that once authorized it should redirect to the specified URL. You will note that your supermarket is running at port: 3000 and with protocol: http but here we are setting up the port: 4000 and protocol: https as the chef server is running in https hence it will expect the redirect url to be a https url. We will be running an nginx server which will accept https request at port 4000 and the nginx server will then redirect the request to our supermarket server which will be running at port: 3000 and protocol: http. Check the next steps.
- Once you have made the modifications to `chef-server.rb` reconfigure the server by running`chef-server-ctl reconfigure`
- The `supermarket.json` file in `/etc/opscode/oc-id-applications` will contain the client id(uid) and secret token(secret) as follows:  

    ```json
    {
    "name": "supermarket",
    "uid": "<supermarket client id>",
    "secret": "<secret token for supermarket>",
    "redirect_uri": "https://localhost:4000/auth/chef_oauth2/callback",
    "scopes": []
    }
    ```

- You need to take the uid and secret and add both in your supermarket configuration.
- Check the IP address of the Chef Infra Server by running `ifconfig`
        Take the value against: eth1. The IP would be something like: 192.168.33.100

## Supermarket Setup

-   Go to the supermarket repo. Then run:
    -   `cd src/supermarket`
-   Modify the .env file and add the generated uid and secret against the parameters:
    -   `CHEF_OAUTH2_APP_ID: <uid>`
    -   `CHEF_OAUTH2_SECRET: <secret>`
-   Also add the chef-server host address against the following parameter as follows:
    -   `CHEF_OAUTH2_URL=https://id.chef.io/`  
        Note that we are using a named server. But we will be pointing this to our local chef-server IP in the following step.
-   Now create a hosts mapping in /etc/hosts file in your machine as follows so that any request to chef-server goes to the chef server IP:
    -   `<chef-server IP> api.chef-server.dev manage.chef-server.dev id.chef.io`
-   Change the port and protocol so that those match with the redirect url set in the chef-server as follows:
    -   `PORT=4000`
    -   `PROTOCOL=https`
-   Now edit the Procfile so that the rails server starts at port 3000 as follows:
    -   `web: bundle exec rails server --binding localhost -p 3000`
-   This is the end of supermarket setup. Now let’s move to nginx configuration.

## Nginx Setup

-   Install Nginx in mac using Homebrew
    -   `brew install nginx`
-   generate ssl ceritificate
    -   `openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /usr/local/etc/nginx/cert.key -out /usr/local/etc/nginx/cert.crt`
-   Go to /usr/local/etc/nginx and update the conf file as follows:

```
worker_processes  1;
events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    sendfile        on;
    keepalive_timeout  65;
    server {
        listen       4000 ssl;
        server_name  localhost;
        ssl_certificate      cert.crt;
        ssl_certificate_key  cert.key;
        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;

        location / {
            proxy_pass http://localhost:3000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header origin 'https://localhost:4000';
        }
    }
}


```

-   start Nginx
    -   brew services start nginx