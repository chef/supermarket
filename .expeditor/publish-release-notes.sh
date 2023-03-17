#!/bin/bash

set -eou pipefail

git clone https://x-access-token:${GITHUB_TOKEN}@github.com/chef/supermarket.wiki.git

pushd ./supermarket.wiki
  # Publish release notes to S3
  aws s3 cp Pending-Release-Notes.md "s3://chef-automate-artifacts/release-notes/${EXPEDITOR_PRODUCT_KEY}/${EXPEDITOR_VERSION}.md" --acl public-read --content-type "text/plain" --profile chef-cd
  aws s3 cp Pending-Release-Notes.md "s3://chef-automate-artifacts/${EXPEDITOR_CHANNEL}/latest/${EXPEDITOR_PRODUCT_KEY}/release-notes.md" --acl public-read --content-type "text/plain" --profile chef-cd

  # Reset "Stable Release Notes" wiki page
  cat >./Pending-Release-Notes.md <<EOH

## Bug Fixes

## Enhancements

## Packaging

## Security

EOH

  # Push changes back up to GitHub
  git add .
  git commit -m "Release Notes for promoted build $EXPEDITOR_VERSION"
  git push origin master #dont change it to main
popd

rm -rf supermarket.wiki
