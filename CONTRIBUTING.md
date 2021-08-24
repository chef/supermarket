# Contributing to Supermarket

Thanks for your interest in contributing to Supermarket!

The basic process:

- Create a git topic branch for your patch and push it to GitHub
- Sign all of your commits with DCO (Developer Certificate of Origin)
- Open a pull request

## The Apache License and Contributing

Licensing is very important to open source projects, it helps ensure the software continues to be available under the terms that the author desired. Chef uses the Apache 2.0 license to strike a balance between open contribution and allowing you to use the software however you would like to.

The license tells you what rights you have that are provided by the copyright holder. It is important that the contributor fully understands what rights they are licensing and agrees to them. Sometimes the copyright holder isn't the contributor, most often when the contributor is doing work for a company.

For more information about licensing, copyright, and why we use DCO, see Chef's [Community Contributions](https://docs.chef.io/community_contributions/) page.

For information on how to sign your commits with DCO, please see [DCO Sign Off Methods](https://github.com/chef/chef/blob/main/CONTRIBUTING.md#dco-sign-off-methods).

## Working with the community

These resources will help you learn more about Chef and connect to other members of the Chef community:
- [Chef](https://discourse.chef.io/) mailing list
- [Chef community slack](http://community-slack.chef.io/)

Also here are some additional pointers to some awesome Chef content:
- [Chef Docs](https://docs.chef.io/)
- [Learn Chef](https://learn.chef.io/)
- Chef [product page](https://www.chef.io/products/chef-infra)

## Overview
If you're experienced with the toolchain, here are the steps for submitting a patch to Supermarket:

1. [Fork the project](https://github.com/chef/supermarket/fork) on GitHub.
2. Create a feature branch:
  ```
  $ git checkout -b my_feature
  ```
3. Make your changes, writing excellent commit messages and adding appropriate test coverage.
4. Open a [Pull Request](https://github.com/chef/supermarket/pull) against the supermarket master branch on GitHub

## Helpful Tips

### Writing Commit Messages

Commit messages should be in the present tense, starting with an action verb, and contain a full predicate. Additional information, such as justification or helpful links, may be added after the commit header. See [0f1ef3fe54](https://github.com/chef/supermarket/commit/0f1ef3fe54) for an example multi-line commit.

```text
Bad:  Added some feature
Bad:  Adding some feature
Good: Add some feature
```

### Running Locally

#### Known issues with `bundle install`

- the `ruby-filemagic` gem fails to build natively:
  ```
  Gem::Ext::BuildError: ERROR: Failed to build gem native extension.

      current directory:  /path/to/your/gems/ruby-filemagic-0.7.1/ext/filemagic
  /path/to/your/ruby/bin/ruby -r ./siteconf20170901-8901-w35pcu.rb extconf.rb
  checking for -lgnurx... no
  checking for magic_open() in -lmagic... no
  *** ERROR: missing required library to compile this module
  *** extconf.rb failed ***
  ```

  This gem [requires](https://stackoverflow.com/questions/15577171/missing-library-while-installing-ruby-filemagic-gem-on-linux) that the `libmagic` library be installed before its native extensions will build.

  For Linux: `sudo apt-get install libmagic-dev`

  For Mac: `brew install libmagic`

  Then `gem` or `bundle` install again.

- the `pg` gem fails to build natively:
  ```
  Gem::Ext::BuildError: ERROR: Failed to build gem native extension.

    current directory: /path/to/your/gems/pg-0.20.0/ext
  /path/to/your/ruby/ruby -r ./siteconf20170901-11813-1qvk88g.rb extconf.rb
  checking for pg_config... no
  No pg_config... trying anyway. If building fails, please try again with
   --with-pg-config=/path/to/pg_config
  checking for libpq-fe.h... no
  Can't find the 'libpq-fe.h header
  *** extconf.rb failed ***
  ```

  For Linux: `sudo apt-get install libpq-dev`

  For Mac: `brew update` then `brew install postgresql`

  Then `gem` or `bundle` install again.

### Writing Tests

In order to ensure the integrity of the project (and prevent regressions), we _cannot_ merge any patch that does not have adequate test coverage. Even if you have never written tests before, the existing tests serve as great boilerplate examples. At minimum, changes to a model must have a unit spec, changes to a controller must have a request spec, changes to a view must have a view or capybara spec, changes to the javascript must have a poltergeist spec.

### Running Tests

There is `docker-compose.yml` file in `src/supermarket` which configures a [`Docker`](https://www.docker.com/) container to host postgres and redis for local development.

In `src/supermarket`:

```
docker-compose up
bundle exec rake db:setup
```

The first line starts up the docker container to make redis and postgres available to the specs by mapping the expected ports. The rake task then initializes the `supermarket_test` db schema expected by the specs.

Finally, `bundle exec rake -T` will show you the available tasks.

You can run all or a subset of the specs:

```
bundle exec rake spec:views
```

### Adding Dependencies

If you are adding dependencies to the project (gems in the Gemfile or npm packages in `packages.json`, please run `license_finder` to make sure that none of the added dependencies conflict  with the project's whitelisted licenses.

### Code Style

[Chefstyle](https://github.com/chef/chefstyle) is used to enforce a specific Ruby style guide. This tool can let you know what the offenses are and where they occur.

It is worth noting that Travis CI runs Chefstyle and will fail the build if it detects any style violations.

Before opening your PR you can run Rubocop locally in the `src/supermarket` directory:

```
bundle exec chefstyle
```

### CSS

[Foundation](http://foundation.zurb.com) is used as a CSS framework and for various bits of JavaScript functionality. The Foundation framework is included in its entirety and is overwritten within the application. Most of the overrides are just small color and typographical changes so most of the [Foundation Docs](http://foundation.zurb.com/docs) apply to Supermarket. One exception is the use of the grid presentational classes (row, x columns, etc.) are eschewed in favor of using the SCSS grid mixins. You can find more information about the SCSS grid mixins [here](http://foundation.zurb.com/docs/components/grid.html).

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
