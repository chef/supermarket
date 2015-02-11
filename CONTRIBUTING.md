Contributing to Supermarket
===========================
Thanks for your interest in contributing to Supermarket!

The basic process:
* Sign a Chef CLA (see below)
* Create a git topic branch for your patch and push it to GitHub
* Open a pull request

The Apache License and Chef Contributor License Agreements
-----------------------------------------------------------
Licensing is very important to open source projects, it helps ensure the software continues to be available under the terms that the author desired.
Chef uses the Apache 2.0 license to strike a balance between open contribution and allowing you to use the software however you would like to.

The license tells you what rights you have that are provided by the copyright holder. It is important that the contributor fully understands what rights
they are licensing and agrees to them. Sometimes the copyright holder isn't the contributor, most often when the contributor is doing work for a company.

To make a good faith effort to ensure these criteria are met, Chef requires a Contributor License Agreement (CLA) or a Corporate Contributor License
Agreement (CCLA) for all contributions. This is without exception due to some matters not being related to copyright and to avoid having to continually
check with our lawyers about small patches.

It only takes a few minutes to complete a CLA, and you retain the copyright to your contribution.

You can [become a contributor by signing the ICLA or by contributing on behalf of your company](https://supermarket.chef.io/become-a-contributor).

For more information about licensing, copyright, and CLAs see Chef's [Community Contributions](https://docs.chef.io/community_contributions.html) page.

Working with the community
--------------------------
These resources will help you learn more about Chef and connect to other members of the Chef community:

* [chef](http://lists.chef.io/sympa/info/chef) and [chef-dev](http://lists.chef.io/sympa/info/chef-dev) mailing lists
* #chef and #chef-hacking IRC channels on irc.freenode.net
* [Chef docs](https://docs.chef.io)
* Chef [product page](https://www.chef.io/chef)

Overview
--------
If you're experienced with the toolchain, here are the steps for submitting a patch to Supermarket:

1. [Fork the project](https://github.com/chef/supermarket/fork) on GitHub
1. Create a feature branch:

        $ git checkout -b my_feature

1. Make your changes, writing excellent commit messages and adding appropiate test coverage
1. Open a [Pull Request](https://github.com/chef/supermarket/pull) against the supermarket master branch on GitHub


Helpful Tips
------------
### Writing Commit Messages
Commit messages should be in the present tense, starting with an action verb, and contain a full predicate. Additional information, such as justification or helpful links, may be added after the commit header. See [0f1ef3fe54](https://github.com/chef/supermarket/commit/0f1ef3fe54) for an example multi-line commit.

```text
Bad:  Added some feature
Bad:  Adding some feature
Good: Add some feature
```

### Writing Tests
In order to ensure the integrity of the project (and prevent regressions), we _cannot_ merge any patch that does not have adequate test coverage. Even if you have never written tests before, the existing tests serve as great boilerplate examples. At minimum, changes to a model must have a unit spec, changes to a controller must have a request spec, changes to a view must have a view or capybara spec, changes to the javascript must have a polgergist spec.

### Adding Dependencies
If you are adding dependencies to the project (gems in the Gemfile or npm
packages in `packages.json`, please run `license_finder` to make sure that none
of the added dependencies conflict  with the project's whitelisted licenses.

### Code Style

[Rubocop](https://github.com/bbatsov/rubocop) is used to enforce a specific Ruby
style guide. You can run Rubocop by runninng the `rubocop` command. Rubocop will
let you know what the offences are and where they occur. It is also worth noting
that Travis CI runs Rubocop, and the build will fail if Rubocop fails.

### CSS

[Foundation](http://foundation.zurb.com) is used as a CSS framework and for
various bits of JavaScript functionality. The Foundation framework is included in
its entirety and is overriden within the application. Most of the overrides are
just small color and typographical changes so most of the [Foundation Docs](http://foundation.zurb.com/docs)
apply to Supermarket. One exception is the use of the grid presentational classes
(row, x columns, etc.) are eschewed in favor of using the SCSS grid mixins. You can
find more information about the SCSS grid mixins [here](http://foundation.zurb.com/docs/components/grid.html).

We adhere to the following SCSS style guidelines:

- Alphabetize SCSS attributes within each declaration with the exception of includes, all `@include` statements should be grouped and come before all other attributes.
- HTML elements such as h1, h2, p, etc. should come first per file, classes second and IDs after.
- Media queries should only contain a single declaration and should be declared immediately following the original.
- For nested styles pretzels should come first then the same guidelines as above apply after.
- Be mindful of nesting, nest only when necessary and avoid deeply nested elements.

Here's an example of SCSS that adheres to these guidelines:

```scss
.activity_heading {
  @include clearfix;
  border-bottom: rem-calc(2) solid lighten($secondary_gray, 35%);

  a {
    float: right;
    font: $bold rem-calc(12) $default_font;
    text-decoration: underline;
  }

  h3 {
    float: left;
    margin-bottom: rem-calc(20);
  }

  .followers {
    text-decoration: underline;
  }

  #follower-count {
    font-size: rem-calc(20);
  }

  @media #{$small-only} {
    font-size: rem-calc(10);
  }
}
```
