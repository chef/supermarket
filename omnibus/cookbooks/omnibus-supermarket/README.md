# Supermarket Cookbook for Omnibus install

This is the cookbook that the Supermarket Omnibus package runs for various
tasks, like the ones that `supermarket-ctl` uses.

## Recipes

Some notable recipes included here are:

* default: Run with `supermarket-ctl reconfigure`

## Testing

### Unit

To get set up run:

```sh
gem install bundler
bundle
```

Run `bundle exec rspec` to run the [RSpec](http://rspec.info/) and
[ChefSpec](http://sethvargo.github.io/chefspec/) specs in the spec directory.

### Integration

Integration tests use [Test Kitchen](http://kitchen.ci/).

Since this cookbook tests the `supermarket-ctl reconfigure` command, you need to
have the Supermarket package installed on the instance you're testing. The Test
Kitchen setup syncs the pkg directory from the parent Omnibus directory
structure into the /tmp/packages directory into the instance under test.

If you create a .kitchen.local.yml in this directory, you can specify the path
to the packages you would like to use:

```yaml
suites:
  - name: default
    run_list:
      - recipe[omnibus-supermarket::cookbook_test]
    attributes:
      supermarket:
        test:
          rpm_package_path: /tmp/packages/supermarket-1.0.0+20141006184237-1.x86_64.rpm
          deb_package_path: /tmp/packages/supermarket-1.0.0+20141006184237-1_amd64.deb
```

To install the package, sync your cookbooks and dependencies from this directory
into /opt/supermarket/embedded/cookbooks, and run `supermarket-ctl reconfigure`,
run `kitchen converge`.

To run the [Serverspec](http://serverspec.org/) tests in
test/integration/default/serverspec, use `kitchen verify`.
