# Release Testing Process

## Install and Smoke Test on Linux EC2 Host

- Using the build version you wish to install run the following command on the test system:
  - `curl https://omnitruck.chef.io/install.sh | bash -s -- -c current -P supermarket -v VERSION_HERE`
- Reconfigured Supermarket with `supermarket-ctl reconfigure`
- You should be able to see the Supermarket homepage in the ec2 instance IP: `https://<Supermarket EC2 instance IP>`.
  _N.B. Your security group of the EC2 instance must be open to incoming and outgoing connections from and to anywhere._
  
## Resolving FQDN Issues

You may face challenges connecting Supermarket with Chef Infra Server's oc-id instance due to the public IP of not being used as FQDN. I was getting error: **redirect uri included is not valid

Initially the FQDN was the private DNS which was something like: **ip-xxx-xx-xx-xxx.us-east-2.compute.internal**

Set the hostname of the instance to the public IP address which was like: <x.xxx.xxx.xxx>
The command used is as follows:
  
```shell
sudo hostnamectl set-hostname <Supermarket EC2 public IP address>
```

Set the same IP in the redirect url in Chef Infra Server oc-id applications as follows:

```json
"redirect_uri": "https://<Supermarket EC2 public IP address>/auth/chef_oauth2/callback"
```

Now it's able to authorize Supermarket with oc-id. But the only issue remains is that it's saying the certificate in Supermarket is self signed and hence not setting the authorization token in cookie when there is a redirect happening from Chef Infra Server to Supermarket callback URL. We need to stop ssl verification of Supermarket for `chef-oauth`. We need to make certain changes in our Supermarket instance configuration to resolve the self signed certificate issue as follows:

- SSH into your Supermarket ec2 instance
- Change user to root user using: `sudo -i`
- `vim /etc/supermarket/supermarket.rb`
- Uncomment and set the value for flag: `default['supermarket']['chef_server_url']`.
- Uncomment the statement of flag: `default['supermarket']['chef_identity_url']`.
- Uncomment and set these two values respectively for flag: `default['supermarket']['chef_oauth2_app_id']` and `default['supermarket']['chef_oauth2_secret']` from your Chef Infra Server `/etc/opscode/oc-id-applications/my_supermarket.json` file.
- Uncomment and add an extra entry `fieri` in the statement with flag : `default['supermarket']['features']` in order to run the quality metrics for cookbooks.
- Uncomment the statements with flag: `default['supermarket']['fieri_url']` & `default['supermarket']['fieri_supermarket_endpoint']`.
- Uncomment and set the value `NmpkMSp9Ts/KvOR/QV+ltLSveA899+LmO0AYZxt0CuA=` for the flag: `default['supermarket']['fieri_key']`
- You should be able to find a statement with the flag: `default['supermarket']['chef_oauth2_verify_ssl']`.
- You need to set the value as `false`.
- Now as you have changed the ssl verification to false you need to reconfigure your Supermarket with the command:
  `supermarket-ctl reconfigure`
- To validate if the changes are properly done you can check the file: `/etc/supermarket/supermarket-running.json`. There you should be able to find the same flag: `chef_oauth2_verify_ssl`. You can validate if it's set to `false`. This will ensure your changes have taken effect.
- Now go to the your development Supermarket website: `https://<Supermarket EC2 public IP address>` and try to login to Supermarket using correct  Chef Infra Server credentials. Authorize Supermarket from the Chef Infra Server page and it should log you in to Supermarket as the Chef Infra Server user.

## Connect to Chef Infra Server using Chef Infra Client

To manage cookbooks between Supermarket and Chef Infra Server we need to install Chef Infra Client in our Supermarket instance to connect to  Chef Infra Server as per the following instructions:

- Get the `<user>.pem` and `<org-validator>.pem` file from your Chef Infra Server into Supermarket server through scp command. You will mostly find these 2 pemfiles in the `/tmp` directory in the  Chef Infra Server host.
- To install chef client in Supermarket instance do the following:
  - ssh into the Supermarket EC2 instance.
  - ```wget https://packages.chef.io/files/stable/chef-workstation/20.6.62/debian/10/chef-workstation_20.6.62-1_amd64.deb```
  - ```sudo dpkg -i chef-workstation*.deb```
- Now create a chef repository in the home directory (e.g. `/home/ubuntu`) your supermarket instance as follows:
  - `chef generate repo chef-repo`
  - You will be able to manage your cookbooks and other resources from inside `chef-repo`
- Inside the chef repo you need to configure your chef server credentials as follows:
  - Create a directory .chef inside the `chef-repo`. Command: `mkdir .chef`
  - Copy the `<user>.pem` and `<org-validator>.pem` to the `.chef` directory. Need to mention these 2 pemfiles in the following step.
  - Create a new file inside chef-repo with: ```vim .chef/config.rb``` and add the following content and replace the placeholders ( e.g. `<placeholder>`) with respective values: 

    ```ruby
    current_dir = File.dirname(__FILE__)
    log_level                :info
    log_location             STDOUT
    node_name                '< Chef Infra Server username>'
    client_key               "< Chef Infra Server username>.pem"
    validation_client_name   '< Chef Infra Server organization name>-validator'
    validation_key           "< Chef Infra Server organization name>-validator.pem"
    chef_server_url          'https://< Chef Infra Server IP>/organizations/ORGNAME'
    cache_type               'BasicFile'
    cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
    cookbook_path            ["#{current_dir}/../cookbooks"]
    ```

Now your Infra Client is configured to connect to the chef server.

### Resolve self signed certificate issue

  Once you have configured your Chef Infra Client to connect to  Chef Infra Server, you need to then resolve the self signed certificate issue of supermarket before you can use the APIs of supermarket for managing(share/unshare/download/install) cookbooks onto the  Chef Infra Server. Follow the steps below:

  - Download the certificate of supermarket server into the supermarket instance. This will make sure when you use supermarket API it doesn't throw an error saying that it's a self signed certificate. Downloading the certificate into trusted certificates will bypass this error of self signed certificate. Follow these steps in sequence.
    - Go to the `chef-repo` directory: `cd chef-repo`
    - `knife ssl fetch https://<supermarket server public IP address>`
    - You can notice that inside the `.chef` directory(inside our `chef-repo`) the certificate has been downloaded in the `trusted_certs` directory with the file name: `<supermarket server IP address>.crt`

**Now the setup is complete to do 2 things i.e. validating supermarket server certificate and being able to connect to the  Chef Infra Server through Chef Infra Client. You should now be able to manage cookbooks onto  Chef Infra Server using supermarket service APIs**

### Upload Cookbook

  - Inside the chef-repo go to the `cookbooks` directory. Command: `cd cookbooks`.
  - Run `chef generate cookbook <cookbook-name>`. This will generate a cookbook directory as per the name given in the command.
  - To push the generated cookbook run the following command:
    - `knife supermarket share <cookbook-name> -m https://<supermarket server IP> -o ~/chef-repo/cookbooks/ -V`
    - If the above command succeeds then that means that your cookbook is pushed through supermarket to the  Chef Infra Server.
  - To verify whether the cookbook is pushed you can go to your supermarket url in your browser and then go to manage profile and you should be able to see the cookbook listed in that page. Here is the url to reach this page: `https://<supermarket IP>/users/< Chef Infra Server username>`.

N.B. I have followed this link to do the whole setup and procedure: https://www.techrepublic.com/article/how-to-install-the- Chef Infra Server-and-chef-client-on-ubuntu-20-04/

### Cookbook Download

To download the cookbook archive use the following command:
`knife supermarket download <cookbook_name> -m https://<supermarket IP>`

### Cookbook Install

To install a cookbook from chef server use the command from supermarket instance:
`knife supermarket install <cookbook_name> -m https://<supermarket IP>`

To validate whether the installation is working fine or not I first deleted the specific cookbook from my chef repo where from I pushed the cookbook.
Then after installing the same cookbook from chef server the same cookbook was put back into the cookbooks directory inside my chef-repo.

### Cookbook Unshare/Delete

To unshare/delete a shared cookbook from chef server use the command:
`knife supermarket unshare <cookbook_name> -m https://<supermarket IP>`

**Once you have completed these steps that means the supermarket version has been verified in terms of basic functional sanity.**

