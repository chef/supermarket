# Fieri

This project rocks and uses MIT-LICENSE.

# Running Quality Metrics

You have several options, depending on what you want to test.

## Within the Fieri Subcomponent

### Write Rspec Tests

To test the nuts and bolts of a particular quality metric, a set of rspec tests
has worked the best for the development team. Examples can be found in
`fieri/spec/models`. (Yes, our workers are models in Fieri mostly because Fieri
exists to run these workers. They're pretty core to this component.)

Run one of the existing worker specs—or one that you're adding!–with a standard
rspec invocation:

```
rspec spec/models/license_worker_spec.rb
```

## Within a Running Development Instance of Supermarket

To have the workers actually execute, it's simplest to run a development instance
of Supermarket itself. See the main README for this repository for running
Supermarket services and their dependencies. Once running, there are a few ways
to trigger quality metrics to be run. Note: these triggers will run each type of
quality metric, not just one in isolation.

### Upload a Cookbook

If you have a sample cookbook to test with, you can upload it to the development
instance:

```
knife supermarket share test_cookbook -m http://localhost:3000 -o /path/to/test

or

stove --endpoint http://localhost:3000/api/v1 --no-git
```

## Run with a Rake command within Supermarket development environment

If a cookbook version has already been uploaded to the development instance, you
can rerun quality metrics against that version with a rake command while in the
root of the Supermarket app (`src/supermarket`):

```
rake quality_metrics:run:on_version[test_cookbook,1.2.3]
```
