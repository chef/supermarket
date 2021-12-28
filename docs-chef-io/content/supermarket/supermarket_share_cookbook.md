+++
title = "Share Cookbooks on the Chef Supermarket"
draft = false
gh_repo = "supermarket"
aliases = ["/supermarket_share_cookbook.html", "/supermarket_share_cookbook/"]

[menu]
  [menu.supermarket]
    title = "Share Cookbooks"
    identifier = "supermarket/Share Cookbooks"
    parent = "supermarket"
    weight = 20
+++

This guide will show you how to share a cookbook on the public [Chef
Supermarket](https://supermarket.chef.io/). The public Supermarket uses
[Hosted Chef](https://manage.chef.io), the Chef-as-a-service provider,
for user authentication. You will need a Hosted Chef account to share
cookbooks.

{{< note >}}

If you already use Hosted Chef as your Chef Infra Server, you can skip
directly to the sharing your cookbook.

{{< /note >}}

## Create a Hosted Chef Account

1. Go to the [Hosted Chef signup page](https://manage.chef.io/signup)
    and enter the requested information to create your account.

2. You will receive a confirmation email. Use the link in the email to
    confirm your confirm your email address.

3. Log in to Hosted Chef and click the **Create New Organization**
    button:

    {{< figure src="/images/hosted_chef_welcome.png" width=600 alt="Image of Chef Manage login window." class="no-shadow" >}}

4. Download and extract the Hosted Chef starter kit:

    {{< figure src="/images/download_starter_kit.png" width=600 alt="Image showing the Administration tab and the Download Starter Kit button.">}}

## Share Cookbooks via Knife

Use the [knife supermarket](/workstation/knife_supermarket/) command to upload
cookbooks to the Supermarket via Knife. In this section you'll configure
the chef-repo that was created by the Hosted Chef starter kit, and then
upload cookbooks from your workstation's cookbook repository.

{{< note >}}

If you're using Hosted Chef as your regular Chef Infra Server, skip to
the second step.

{{< /note >}}

1. The `config.rb` file located under `/chef-repo/.chef/config.rb`
    contains the basic information necessary to authenticate with Hosted
    Chef. It will look similar to the following:

    ```ruby
    current_dir = __dir__
    node_name                'brewn'
    client_key               "#{current_dir}/brewn.pem"
    chef_server_url          'https://api.chef.io/organizations/chfex'
    cookbook_path            ["#{current_dir}/../cookbooks"]
    ```

    However if you're not an existing Hosted Chef user, you've most
    likely created your cookbooks within another repository with its own
    Knife configuration. Instead of modifying your workstation setup,
    simply add the path to your cookbook repository under the
    `cookbook_path` setting in your Hosted Chef chef-repo. For example:

    ```ruby
    cookbook_path            ['~/my-repo/cookbooks']
    ```

2. Use the `knife supermarket` command to upload your cookbook to the
    Supermarket:

    ```none
    knife supermarket share example_cookbook
    ```

    Alternatively, if you choose not to modify the location of your
    cookbook repository within your `config.rb`, you can specify the
    cookbook path in your `knife` command:

    ```none
    knife supermarket share example_cookbook -o ~/my-repo/cookbooks
    ```
