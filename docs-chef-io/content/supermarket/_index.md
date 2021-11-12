+++
title = "Chef Supermarket"
draft = false
gh_repo = "supermarket"
aliases = ["/supermarket.html"]
product = ["client", "server", "workstation"]

[menu]
  [menu.supermarket]
    title = "About Supermarket"
    identifier = "supermarket/About Supermarket"
    parent = "supermarket"
    weight = 10
+++

About supermarket.

Don't merge this.

{{% supermarket_summary %}}

## Public Supermarket

The public Chef Supermarket hosted by Chef Software is located at [Chef
Supermarket](https://supermarket.chef.io/).

To interact with the public Chef Supermarket, use [knife
supermarket](/workstation/knife_supermarket/) commands.

{{< figure src="/images/public_supermarket.svg" width="700" alt="Image showing the Chef Supermarket website." >}}

## Private Supermarket

{{% supermarket_private %}}

{{< note >}}

{{% supermarket_private_source_code %}}

{{< /note >}}
