### Testing on ubuntu 20.04.2 LTS

- Build supermarket artifact with omnibus
  - Go to the supermarket repo. Inside repo go to `omnibus` directory
  - run `bundle install --binstubs`

- Install supermarket artifact
  - Once build is successful it will create a supermarket installation package in the directory `/var/cache/omnibus/pkg`.
    U can install the package using respective package installer for the selected OS. For ubuntu I've used `dpkg` as follows
    ```
      sudo dpkg -i /var/cache/omnibus/pkg/<package>.deb
    ```

- Reconfigured supermarket with `supermarket-ctl reconfigure`

- You should be able to see the supermarket homepage in the ec2 instance IP: `https://<EC2 instance IP>`.
  Please note that your security group of the ec2 instance must be open to incoming and outgoing connections from and to anywhere.
  
### Resolve FQDN Issue

I was facing some challenge connecting supermarket with oc-id due to the public IP not being used as FQDN. Was getting error: **redirect uri included is not valid**

Initially the fqdn was the private DNS which was: **ip-xxx-xx-xx-xxx.us-east-2.compute.internal**

I had to set the hostname to the public IP address which was: <x.xxx.xxx.xxx>
The command used is as follows:
```
sudo hostnamectl set-hostname <ec2 IP address>
```

Had to set the same IP in the redirect url in chef server oc-id applications as follows:
```
"redirect_uri": "https://<ec2 IP address>/auth/chef_oauth2/callback"
```

Now it's able to authorize supermarket with oc-id. But the only issue remains is that it's saying the certificate in supermarket is self signed and hence not setting the authorization token in cookie. Will check what can be done.

Now as the self signed certificate issue is resolved we move on to the next step.

### Upload Cookbook

- We need to install chef-client in our supermarket server to connect to chef-server as per the following instructions:

  - Get the <user>.pem and <org-validator>.pem file from your chef server into supermarket server through scp command. You will mostly find these 2 pemfiles in the /tmp directory in the chef-server host.
  - To install chef client in supermarket instance do the following:
    - ssh into the supermarket ec2 instance.
    - ```wget https://packages.chef.io/files/stable/chef-workstation/20.6.62/debian/10/chef-workstation_20.6.62-1_amd64.deb```
    - ```sudo dpkg -i chef-workstation*.deb```
  - Now create a chef repository in the home directory (e.g. `/home/ubuntu`) your supermarket instance as follows:
    - `chef generate repo chef-repo`
    - This will create a chef repository where you can generate your cookbooks that you want to push into chef server
    - For pushing any cookbook you need to first authorize your chef client with chef server with the previously copied <user>.pem and <org-validator>.pem
  - Inside the chef repo you need to configure your chef server credentials as follows:
    - Create a directory .chef inside the chef-repo.
    - Copy the `<user>.pem` and `<org-validator>.pem` to the `.chef` directory. Need to mention these 2 pemfiles in the following step.
    - Create a new file inside chef-repo with: ```vim .chef/config.rb``` and add the following content and replace the placeholders ( e.g. `<placeholder>`): 

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
    - Now your chef client is configured to connect to the chef server.
    - Next step is to download the certificate of supermarket server in to the supermarket instance. This will make sure when you use supermarket API it doesn't throw an error saying that it's a self signed certificate. Downloading the certificate into trusted certificates will bypass this error of self signed certificate. Run the following command:
      - `knife ssl fetch https://<supermarket server public IP address>`
      - You can notice that inside the `.chef` directory the certificate has been downloaded in the `trusted_certs` directory in the name of the `<supermarket server IP address>.crt`
    - Now the setup is complete to do 2 things i.e. validating supermarket server certificate and being able to connect to the chef-server. You shold now be able to push cookbooks to chef-server using supermarket service API as follows:
    - Inside the chef-repo go to the `cookbooks` directory.
    - Run `chef generate cookbook <cookbook-name>`. This will generate a cookbook directory as per the name given in the command.
    - To push the generated cookbook run the following command:
      - `knife supermarket share <cookbook-name> -m https://<supermarket server IP> -o ~/chef-repo/cookbooks/ -V`
      - If the above command succeeds then that means that your cookbook is pushed through supermarket to the chef-server
    - To verify whether the cookbook is pushed you can go to your supermarket url in your browser and then go to manage profile and you should be able to see the cookbook listed in that page. Here is the url to reach this page: `https://<supermarket IP>/users/<chef-server username>`.

N.B. I have followed this link to do the whole setup and procedure: https://www.techrepublic.com/article/how-to-install-the-chef-server-and-chef-client-on-ubuntu-20-04/


### Cookbook Download
Able to download the cookbook archive with the following command:
`knife supermarket download <cookbook_name> -m https://<supermarket IP>`


### Cookbook Install
I was able to install a cookbook from chef server using the command from supermarket instance:
`knife supermarket download <cookbook_name> -m https://<supermarket IP>`

To validate whether the installation is working fine or not I first deleted the specific cookbook from my chef repo where from I pushed the cookbook.
Then after installing the same cookbook from chef server the same cookbook was put back into the cookbooks directory inside my chef-repo.


### Cookbook Unshare/Delete

I was able to unshare/delete a shared cookbook from chef server using the command:
`knife supermarket unshare <cookbook_name> -m https://<supermarket IP>`

