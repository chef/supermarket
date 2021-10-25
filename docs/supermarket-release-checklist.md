### Testing on ubuntu 20.04.2 LTS

- Clone supermarket repo from Github.
- Go to the supermarket repo.
- Checkout to the release tag of supermarket that you want to test:
  ```
  git checkout <tag version e.g.: 4.0.14>
  ```
- Build supermarket artifact with omnibus
  - Inside repo go to `omnibus` directory
    `cd omnibus`
  - Run `bundle install --binstubs`
  - Run `bin/omnibus build supermarket`
  - Once build is successful it will create a supermarket installation package in the directory `/var/cache/omnibus/pkg`.
  - N.B. For general troubleshooting in building supermarket build package refer to the supermarket setup guidelines in supermaket Github repo.

- Install supermarket
  - U can install the package using respective package installer for the selected OS. For ubuntu I've used `dpkg` as follows:
    ```
    sudo dpkg -i /var/cache/omnibus/pkg/<package>.deb
    ```

- Reconfigured supermarket with `supermarket-ctl reconfigure`

- You should be able to see the supermarket homepage in the ec2 instance IP: `https://<supermarket ec2 instance IP>`.
  _N.B. Your security group of the ec2 instance must be open to incoming and outgoing connections from and to anywhere._
  
### Resolve FQDN Issue

I was facing some challenge connecting supermarket with oc-id due to the public IP not being used as FQDN. Was getting error: **redirect uri included is not valid

Initially the fqdn was the private DNS which was something like: **ip-xxx-xx-xx-xxx.us-east-2.compute.internal**

I had to set the hostname of the instance to the public IP address which was like: <x.xxx.xxx.xxx>
The command used is as follows:
```
sudo hostnamectl set-hostname <supermarket ec2 public IP address>
```

Had to set the same IP in the redirect url in chef server oc-id applications as follows:
```
"redirect_uri": "https://<supermarket ec2 public IP address>/auth/chef_oauth2/callback"
```

Now it's able to authorize supermarket with oc-id. But the only issue remains is that it's saying the certificate in supermarket is self signed and hence not setting the authorization token in cookie when there is a redirect happening from chef-server to supermarket callback URL. We need to stop ssl verification of supermarket for `chef-oauth`. We need to make certain changes in our supermarket instance configuration to resolve the self signed certificate issue as follows:
- SSH into your supermarket ec2 instance
- Change user to root user using: `sudo -i`
- `vim /etc/supermarket/supermarket.rb`
- You should be able to find a statement with the flag: `default['supermarket']['chef_oauth2_verify_ssl']`.
- You need to set the value as `false`.
- Now as you have changed the ssl verification to false you need to reconfigure your supermarket with the command:
  `supermarket-ctl reconfigure`
- To validate if the changes are properly done you can check the file: `/etc/supermarket/supermarket-running.json`. There you should be able to find the same flag: `chef_oauth2_verify_ssl`. You can validate if it's set to `false`. This will ensure your changes have taken effect.
- Now go to the your development supermarket website: `https://<supermarket ec2 public IP address>` and try to login to supermarket using correct chef-server credentials. Authorize supermarket from the chef-server page and it should log you in to supermarket as the chef-server user.

### Connect to chef-server using Chef-Client

To manage cookbooks between supermarket and chef-server we need to install chef-client in our supermarket instance to connect to chef-server as per the following instructions:

- Get the `<user>.pem` and `<org-validator>.pem` file from your chef server into supermarket server through scp command. You will mostly find these 2 pemfiles in the `/tmp` directory in the chef-server host.
- To install chef client in supermarket instance do the following:
  - ssh into the supermarket ec2 instance.
  - ```wget https://packages.chef.io/files/stable/chef-workstation/20.6.62/debian/10/chef-workstation_20.6.62-1_amd64.deb```
  - ```sudo dpkg -i chef-workstation*.deb```
- Now create a chef repository in the home directory (e.g. `/home/ubuntu`) your supermarket instance as follows:
  - `chef generate repo chef-repo`
  - You will be able to manage your cookbooks and other resources from inside `chef-repo`
- Inside the chef repo you need to configure your chef server credentials as follows:
  - Create a directory .chef inside the `chef-repo`. Command: `mkdir .chef`
  - Copy the `<user>.pem` and `<org-validator>.pem` to the `.chef` directory. Need to mention these 2 pemfiles in the following step.
  - Create a new file inside chef-repo with: ```vim .chef/config.rb``` and add the following content and replace the placeholders ( e.g. `<placeholder>`) with respective values: 

    ```
    current_dir = File.dirname(__FILE__)
    log_level                :info
    log_location             STDOUT
    node_name                '<chef-server username>'
    client_key               "<chef-server username>.pem"
    validation_client_name   '<chef-server organization name>-validator'
    validation_key           "<chef-server organization name>-validator.pem"
    chef_server_url          'https://<chef-server IP>/organizations/ORGNAME'
    cache_type               'BasicFile'
    cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
    cookbook_path            ["#{current_dir}/../cookbooks"]
    ```
Now your chef client is configured to connect to the chef server.


### Resolve self signed certificate issue

  Once you have configured your chef-client to connect to chef-server, you need to then resolve the self signed certificate issue of supermarket before you can use the APIs of supermarket for managing(share/unshare/download/install) cookbooks onto the chef-server. Follow the steps below:

  - Download the certificate of supermarket server into the supermarket instance. This will make sure when you use supermarket API it doesn't throw an error saying that it's a self signed certificate. Downloading the certificate into trusted certificates will bypass this error of self signed certificate. Follow these steps in sequence.
    - Go to the `chef-repo` directory: `cd chef-repo`
    - `knife ssl fetch https://<supermarket server public IP address>`
    - You can notice that inside the `.chef` directory(inside our `chef-repo`) the certificate has been downloaded in the `trusted_certs` directory with the file name: `<supermarket server IP address>.crt`

**Now the setup is complete to do 2 things i.e. validating supermarket server certificate and being able to connect to the chef-server through chef-client. You should now be able to manage cookbooks onto chef-server using supermarket service APIs**


### Upload Cookbook

  - Inside the chef-repo go to the `cookbooks` directory. Command: `cd cookbooks`.
  - Run `chef generate cookbook <cookbook-name>`. This will generate a cookbook directory as per the name given in the command.
  - To push the generated cookbook run the following command:
    - `knife supermarket share <cookbook-name> -m https://<supermarket server IP> -o ~/chef-repo/cookbooks/ -V`
    - If the above command succeeds then that means that your cookbook is pushed through supermarket to the chef-server.
  - To verify whether the cookbook is pushed you can go to your supermarket url in your browser and then go to manage profile and you should be able to see the cookbook listed in that page. Here is the url to reach this page: `https://<supermarket IP>/users/<chef-server username>`.

N.B. I have followed this link to do the whole setup and procedure: https://www.techrepublic.com/article/how-to-install-the-chef-server-and-chef-client-on-ubuntu-20-04/


### Cookbook Download
To download the cookbook archive use the following command:
`knife supermarket download <cookbook_name> -m https://<supermarket IP>`


### Cookbook Install
To install a cookbook from chef server use the command from supermarket instance:
`knife supermarket download <cookbook_name> -m https://<supermarket IP>`

To validate whether the installation is working fine or not I first deleted the specific cookbook from my chef repo where from I pushed the cookbook.
Then after installing the same cookbook from chef server the same cookbook was put back into the cookbooks directory inside my chef-repo.


### Cookbook Unshare/Delete

To unshare/delete a shared cookbook from chef server use the command:
`knife supermarket unshare <cookbook_name> -m https://<supermarket IP>`
  
  
**Once you have completed these steps that means the supermarket version has been verified in terms of basic functional sanity.**

