Contributing to Supermarket
===========================
Thanks for your interest in contributing to Supermarket!

The basic process:
* Sign a Chef CLA (see below)
* Create a git topic branch for your patch and push it to github
* Open a pull request

The Apache License and Chef Contributor Lincense Agreements
-----------------------------------------------------------
Licensing is very important to open source projects, it helps ensure the software continues to be available under the terms that the author desired.
Chef uses the Apache 2.0 license to strike a balance between open contribution and allowing you to use the software however you would like to.

The license tells you what rights you have that are provided by the copyright holder. It is important that the contributor fully understands what rights
they are licensing and agrees to them. Sometimes the copyright holder isn't the contributor, most often when the contributor is doing work for a company.

To make a good faith effort to ensure these criteria are met, Chef requires a Contributor License Agreement (CLA) or a Corporate Contributor License
Agreement (CCLA) for all contributions. This is without exception due to some matters not being related to copyright and to avoid having to continually
check with our lawyers about small patches.

It only takes a few minutes to complete a CLA, and you retain the copyright to your contribution.

You can complete our contributor agreement (CLA) [
online](https://secure.echosign.com/public/hostedForm?formid=PJIF5694K6L).  If you're contributing on behalf of your employer, have
your employer fill out our [Corporate CLA](https://secure.echosign.com/public/hostedForm?formid=PIE6C7AX856) instead.

For more information about licensing, copyright, and CLAs see Chef's [Community Contributions](http://docs.opscode.com/community_contributions.html) page.

Working with the community
--------------------------
These resources will help you learn more about Chef and connect to other members of the Chef community:

* [chef](http://lists.opscode.com/sympa/info/chef) and [chef-dev](http://lists.opscode.com/sympa/info/chef-dev) mailing lists
* #chef and #chef-hacking IRC channels on irc.freenode.net
* [Chef docs](http://docs.opscode.com)
* Chef [product page](http://www.opscode.com/chef)


Overview
--------
If you're experienced with the toolchain, here are the steps for submitting a patch to Supermarket:

1. [Fork the project](https://github.com/opscode/supermarket/fork) on GitHub
1. Create a feature branch:

        $ git checkout -b my_feature

1. Make your changes, writing excellent commit messages and adding appropiate test coverage
1. Open a [Pull Request](https://opscode.com/opscode/supermarket/pull) against the supermarket master branch on GitHub


Helpful Tips
------------
### Writing Commit Messages
Commit messages should be in the present tense, starting with an action verb, and contain a full predicate. Additional information, such as justification or helpful links, may be added after the commit header. See [0f1ef3fe54](https://github.com/opscode/supermarket/commit/0f1ef3fe54) for an example multi-line commit.

```text
Bad:  Added some feature
Bad:  Adding some feature
Good: Add some feature
```

### Writing Tests
In order to ensure the integrity of the project (and prevent regressions), we _cannot_ merge any patch that does not have adequate test coverage. Even if you have never written tests before, the existing tests serve as great boilerplate examples. At minimum, changes to a model must have a unit spec, changes to a controller must have a request spec, changes to a view must have a view or capybara spec, changes to the javascript must have a polgergist spec.
