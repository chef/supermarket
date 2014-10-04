# Supermarket Cookbook for Omnibus install

This is the cookbook that the Supermarket Omnibus package runs for various
tasks, like the ones that `supermarket-ctl` uses.

## Recipes

Some notable recipes included here are:

* default: Run with `supermarket-ctl reconfigure`

## Testing

### Specs

From this directory, run `bin/rspec` to run the [RSpec](http://rspec.info/) and
[ChefSpec](http://sethvargo.github.io/chefspec/) specs in the spec directory.
