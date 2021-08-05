# Chef Supermarket Release Cadence

Chef Supermarket follows [Semantic Versioning](https://semver.org/) for releases. Major versions (eg. 3.x -> 4.x) will include backwards-incompatible changes or changes that require migration events which may include significant downtime. Minor versions (eg 3.1 -> 3.2) will include new features and bug fixes, but will be backwards-compatible to the best of our ability. Patch releases will contain bug and security fixes only.

## Current Process
Right now the buildkite pipeline is green so we will have builds hitting the current channel and those require a bit of hand validation.

We need to install the build and make sure everything looks correct and functions properly then we will open a ticket to ops to deploy that to `https://supermarket-staging.chef.io/`

Once that is done and we validate it, We can promote it to the stable channel for on premise customers and raise a ticket to ops to deploy it to the production site.
