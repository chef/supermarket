Sometimes cookbooks on <https://supermarket.chef.io/> lose their maintainer for one reason or another. In the event that happens, and another maintainer wants to pick up that cookbook, the Chef Community wants to allow for the adoption of those cookbooks.

When a Cookbook is Up For Adoption
----------------------------------

When a cookbook owner puts the cookbook up for adoption(which will be reflected in the supermarket interface by the presence of an "Adopt me!" button), that means they no longer wish to be the owner and maintainer of the cookbook. At anytime another supermarket user can click on the "Adopt Me!" button on the cookbook's page on Supermarket and the current owner of the cookbook will be notified. The owner can then transfer ownership to the user who wants it.

When a Cookbook is Up For Adoption Without Response from Current Owner
----------------------------------------------------------------------

If you find a cookbook that is up for adoption, and I have offered to adopt it though SuperMarket, but the cookbook owner has not responded in a reasonable amount of time, the prospective adopter should reach out to the current owner in other ways (email, issue on the cookbook repo, social media, etc). If the owner is still unresponsive, the prospective can request that Supermarket administrators make the transfer on behalf of the current owner.

When a Cookbook is NOT Already Up for Adoption
----------------------------------------------

### Simplest Path

There are already mechanisms in place in Supermarket, GitHub, and other code repositories for transferring ownership. It is not the normal policy of Chef Software to transfer ownership of a cookbook to anyone else without their consent; that is left to the cookbook's current owner. See above for guidelines on when a cookbook has been placed up for adoption.

-   As a member of the Chef Community,

-   When I (a person hoping to take ownership of the cookbook) believe that ownership of a cookbook should be transferred,

-   I will contact the current owner to discuss ownership transfer.

### Contacting the Current Owner

If the cookbook has not yet been put up for adoption, the party hoping to take ownership of the cookbook should reach out to the current owner. The request should be made through as many avenues as possible, for example: starting a conversation on Chef Community Slack, opening a GitHub issue on the cookbook, sending the owner an email, reaching out to the owner over social media. We strongly recommend that you do not bombard the current owner though all avenues at once, but if the owner is unresponsive through one avenue, try another.

One example of outreach might be:

> Hi there! You are currently the owner of this cookbook on [supermarket.chef.io](http://supermarket.chef.io), and I would like to discuss you potentially transferring this ownership to the Sous Chefs organization. The only action required of you to make the transfer on supermarket happen would be a reply confirming your acceptance, and we'll be able to handle that side! Transfer of the GitHub repo will need to be triggered by following the GitHub directions: [insert link to directions]

We expect the current owner to be allowed ample time to respond, generally relative to their activity in a given platform. For example, if the user is relatively inactive on GitHub, it may take a few weeks to months to see a response there. If a user is more active on Twitter, it would be expected that a response would be more timely. In general, lack of response to requests made on platform where the user is active may result in a decision against transferring of ownership.

### So, You Can't Reach The Owner

We do recognize, however, that there are extreme circumstances making the owner unreachable (e.g. death of the current owner). In these cases:

-   I (the person hoping to take ownership of the cookbook) will describe the situation to the community in a post on [Discourse](http://discourse.chef.io) using the format below

The requests will be decided on a case-by-case basis, by a panel with an odd number of members consisting of both Chef Software employees and community members.

Results and any status updates will be tracked in the thread of the original post on [Discourse.](http://discourse.chef.io)

... when an owner is unresponsive to multiple requests for ownership transfer and there are no apparent extreme circumstances (e.g. they're active on those platforms, but you've been ghosted):

-   Transfer of ownership without consent is not appropriate,

-   I (the person hoping to take ownership of the cookbook) can start a discussion with the Chef Community in [Discourse](http://discourse.chef.io) (format below) suggesting that a stale cookbook be deprecated in favor of some other cookbook.

Format for Discussing Cookbook Ownership/Deprecation Status
-----------------------------------------------------------

> **Request**
>
> [insert request here, include links to cookbook and code repo]
>
> eg: The Sous Chefs request that the MongoDB cookbook on Supermarket be marked deprecated in favor of [sc-mongodb](https://github.com/sous-chefs/mongodb) on Supermarket.
>
> or
>
> I request that the ownership of the cookbook be transferred to me because it has been up for adoption for six months. I am willing to maintain this cookbook in the future.
>
> **History of the cookbook**
>
> [insert relevant history and current state of the cookbook]
>
> [insert relevant history of attempts to transfer ownership]