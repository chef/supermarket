# Supermarket Changelog

<!-- latest_release -->
<!-- latest_release -->

<!-- release_rollup -->
<!-- release_rollup -->

<!-- latest_stable_release -->
<!-- latest_stable_release -->

## 3.1.25 (2017-08-16)

**Security Updates**

+ updated embedded git to v2.14.1 to address CVE-2017-1000117 [#1653]
+ updated OpenSSL to v1.0.2k (CVE-2017-3731, CVE-2017-3732, CVE-2016-7055) [#1653]
+ updated PostgreSQL to v9.3.18 (CVE-2017-7547, CVE-2017-7546, CVE-2017-7486, CVE-2017-7484, CVE-2017-7485) [#1654]

## 3.1.23 (2017-08-10)

**Fixes**

+ Upgraded sysctl cookbook internal to the omnibus install should fix installs on RHEL-like OSes (e.g. SuSE). [#1649]

**Updates**

+ Upgraded quality metrics to use Foodcritic v11.3.0. [#1648]

## 3.1.22 (2017-07-24)

**Fixes**

+ Fix Foodcritic and No Binaries quality metrics (use the new method signature for retrieving the cookbook tarball). [#1621]

**Updates**

+ Upgraded Ruby to v2.4.1 [#1627]
+ Several changes to internal test/build pipeline.

## 3.1.14 (2017-06-17)

**Security Updates**

+ Includes an updated version of zlib dependency [#1620]

**Updates**

+ Upgraded Foodcritic to v11.2.0 [#1618]
+ Changed links to old IRC to new Chef Community Slack [#1603]

## 3.1.10 (2017-06-14)

**Security Fixes**

+ Fixes secret token checking for Fieri, the quality metrics job runner [#1607]

**Fixes**

+ Fixes a bug in the Collaborator Groups feature where users were not getting added as collaborators when a group they are a member of was added to a cookbook. [#1607]

**Updates**

+ Upgrade web application from Rails 4.2 to 5.0 [#1607]
+ Minor internal changes to the implementation of feature flags [#1616]

**Deprecations/Removals**

+ Individual/Corproate Contributor License Agreement tracking (a.k.a. Curry) has been removed after a period of deprecation. [#1608]

## 3.1.6 (2017-05-19)

**Enhancements**

* More Foodcritic rules included with an upgrade to v11.1.0 [#1610, #1611]

## 3.1.4 (2017-05-15)

**Fixes**

+ Display a useful message when a user's account does not have a public_key associated with it. [#1600]
+ Update versions of embedded monitoring agents (Datadog, New Relic, Sentry). [#1605]

## 3.1.1 (2017-04-24)

**Enhancement**

* Added subcommands to `supermarket-ctl` to change the visibility of quality metrics. [#1599]

## 3.1.0 (2017-04-20)

**New Behavior**

* The cookbook quality metrics currently implemented have all been changed to publicly visible as a default for new installations. For existing pre-3.1.0 Supermarket installations, this release will _not_ automatically change the public visibility of metrics. [#1596]

**Fixes**

* Reënable Foodcritic rule FC045 now that the version of Foodcritic included doesn't alert when a cookbook is published without metadata.rb. [#1593]
* Display quality metric results in a consistent order. [#1595]
* Update links to mailing list to take readers to the Chef Community Mailing List (Discourse site). Thanks to [Roland Moriz](https://github.com/rmoriz) for the catch and fix! [#1598]

## 3.0.2 (2017-04-13)

**Updates**

+ Update to Foodcritic 10.3.1 for new rules, particularly around licensing. (#1590)

**Bugs Fixed**

 + Provide an omnibus configuration default fallback to bare hostname for a Supermarket's FQDN when a host's FQDN is indeterminate. Production Supermarket instances are generally expected to have an FQDN specified in an override—or at least be reliably resolvable via ohai on a single host—so that production SSL certificates have a stable name to match against. This fallback fix is expected to solve a problem that only should occur in test environments. (Fixes #1591 via #1592)

## 3.0.0 (2017-04-10)

**⚠️ Breaking Change ⚠️**

**Attention: AWS S3 Users**

Private Supermarkets using AWS S3 have two new settings to consider following an upgrade to the Paperclip and AWS SDK gems:

+ `s3_region` _must_ be set for the bucket in which cookbooks will be stored.
+ `s3_domain_style` has a new default of `:s3_domain_url`. However, if the S3 bucket name contains periods (`.`), the bucket _must_ be in AWS US-East-1 and the `s3_domain_style` _must_ be `:s3_path_url`.

The `supermarket-ctl reconfigure` action will error with an exception and message if these settings are missing or incompatible.

**Updates**

+ Upgraded Paperclip and AWS SDK gems. (#1411)
+ Upgraded the New Relic and Datadog monitoring agents. (#1588 & #1589)

**Bugs Fixed**

+ Fixed binary file detection to not think zero-byte empty files are binary. (#1584)
+ Added the current ChefDK version of open source license strings as acceptable for the license quality metric. (#1586)
+ Fixed inconsistencies in the display of the navigation menus between the top nav bar and the left side drawer menu. (#1411)

## 2.9.30 (2017-04-04)

**Bugs Fixed**

+ Fixed looking up GitHub repo identifiers from source_url for quality metrics that check on a source repository (same fix as in 2.9.29, but applied to the other workers). (#1583)
+ Upgrade Octokit client to v4+ to support GitHub API's new redirect behavior. (Also #1583)

## 2.9.29 (2017-04-03)

**Enhancements**

+ License quality metric now standardized on checking against SPDX format license strings. (#1577)
+ Upgraded to [Foodcritic 10.2.2](https://github.com/acrmp/foodcritic/blob/master/CHANGELOG.md#1022-2017-03-31) for new rules and fixes. (#1582)
+ Upgraded to latest Ruby 2.3 (2.3.3). (#1581)

**Bugs Fixed**

+ Fixed displaying the first and last name or username of the person publishing a new version of a cookbook in the activity feed. (#1578)
+ Fixed looking up GitHub repo identifiers from source_url for quality metrics that check on a source repository. (#1579)

## 2.9.21 (2017-03-17)

**Enhancements**

+ **New Quality Metrics**:
    + [QM012](https://github.com/chef-cookbooks/cookbook-quality-metrics/blob/fda3f14d9199bfd1bb894d00e7a8e25c85a6b35d/quality-metrics/qm-012-binaries.md) - cookbook artifact does not include binary files
    + [QM014](https://github.com/chef-cookbooks/cookbook-quality-metrics/blob/fda3f14d9199bfd1bb894d00e7a8e25c85a6b35d/quality-metrics/qm-014-version_tags.md) - source repo has a version tag present that matches the version declared in metadata

**Security Update**

+ Upgraded Rails and Nokogiri to address [CVE-2016-4658](http://people.canonical.com/~ubuntu-security/cve/2016/CVE-2016-4658.html) and [CVE-2016-5131](http://people.canonical.com/~ubuntu-security/cve/2016/CVE-2016-5131.html) in [libxml2 vendored within Nokogiri](https://github.com/sparklemotion/nokogiri/issues/1615).


## 2.9.15 (2017-03-14)

**Enhancements**

+ **New Quality Metrics** that check a cookbook's GitHub repository (if present):
    + [QM011](https://github.com/chef-cookbooks/cookbook-quality-metrics/blob/fda3f14d9199bfd1bb894d00e7a8e25c85a6b35d/quality-metrics/qm-011-contributing_doc.md) - cookbook includes instructions on how to contribute (CONTRIBUTING
      document)
    + [QM013](https://github.com/chef-cookbooks/cookbook-quality-metrics/blob/fda3f14d9199bfd1bb894d00e7a8e25c85a6b35d/quality-metrics/qm-013-testing_doc.md) - cookbook includes instructions on how to test (TESTING document)
+ **Rerun Quality Metrics** with supermarket-ctl commands added. A sysadmin/operator can re-run quality metrics on the latest versions of all cookbooks, on the latest version of a single cookbook, or on a specific version of a single cookbook.
+ **Optional Dedicated Redis for Jobs** Provide an optional configuration item
`['supermarket']['redis_jobq_url']` to  specify a Redis connection URL specific
to handling the background job queue. This allows a Supermarket to separate job
processing needs from operations that affect request response times like caching
and feature flag checks.

**Fixes**

+ Remove duplicate quality metric results produced by re-runs.
+ Reliably disable the Datadog application metrics tracer. No more log spam!

## 2.9.7 (2017-02-17)

**Enhancements**

- **Configurable API item limit**:: Use `api_item_limit` in the configuration passed to omnibus install to set the upper limit on the number of items to return for API requests. Defaults to 100 items.
- **Datadog APM Tracer included**:: The Supermarket web application now includes the Datadog APM Tracer agent. The agent defaults to disabled, but can be turned on with `datadog_tracer_enabled` for a Supermarket instance to be monitored with [Datadog APM](https://www.datadoghq.com/apm/).

## 2.9.3 (2017-02-02)

**Enhancements**

- New quality metric to check for [a cookbook declaring what platforms it supports](https://github.com/chef-cookbooks/cookbook-quality-metrics/blob/52be6b20a891e0b2f0915df2ec58beb5588141b5/quality-metrics/qm-006-supports.md).

**Fixes**

- Trim the temporary directory from the foodcritic metric output to reduce the noise in its feedback.
- Fix linkage to the Supermarket API documentation.

**Security Update**
- Update to mixlib-archive used in the Fieri component to address a security vulnerability in handling tar files. If you run Fieri in your private Supermarket, this is a recommended upgrade.

## 2.8.61 (2017-01-30)

**Enhancements**

- Cookbook version API endpoint now includes `published_at` the publication date  on which the version was uploaded to Supermarket.
- Cookbook view displays supported `chef_versions` and `ohai_versions` for currently selected cookbook version if those values exist in the cookbook metadata.
- Several updates to user profile display and management:
  - The Keys tab under user profile management now displays the fingerprint for the public key associated with the user. Instructions are also given for verifying this fingerprint matches the user's local workstation key and for how to tell Supermarket to update its copy of the user's key from the associated Chef Server.
  - Field label text added for contact information. Previously, the label text would only appear in empty fields in the form.
  - JIRA username removed.

**Fixes**

- Upgrade to runit cookbook used in the omnibus install and configuration.
- Upgrade project to Ruby 2.3.1.
- Tweaks to the nginx log format to make it more easily parsed.

**Deprecations**

- CLA signatures and management have been removed from the user profile tabs.

## 2.8.43 (2016-12-05)

**Enhancements**

- **Admin-Only Quality Metrics**: In the effort to add new quality metrics to the system, metrics can now be flagged as only visible to Supermarket admins. As metrics are added and tested, they will start as admin-only. Toggling involves console commands as of this release and will become easier as this feature gets fleshed out!
- **New Quality Metrics** (set to admin-only by default):
  - [QM001](https://github.com/chef-cookbooks/cookbook-quality-metrics/blob/52be6b20a891e0b2f0915df2ec58beb5588141b5/quality-metrics/qm-001-published.md): Cookbook is published to the Supermarket and not deprecated or up for adoption.
  - [QM003](https://github.com/chef-cookbooks/cookbook-quality-metrics/blob/52be6b20a891e0b2f0915df2ec58beb5588141b5/quality-metrics/qm-003-license.md): Cookbook released under a recognized open source license.
- Upgraded Fieri's Foodcritic to v8.1.0+

**Fixes**

- Set default configuration for Foodcritic metric to match that declared by [QM009](https://github.com/chef-cookbooks/cookbook-quality-metrics/blob/52be6b20a891e0b2f0915df2ec58beb5588141b5/quality-metrics/qm-009-foodcritic.md)

**Meta**
- Clarify contributing instructions around the Developer's Certificate of Origin
- Add a [code of conduct](https://github.com/chef/supermarket/blob/master/CODE_OF_CONDUCT.md), referencing the Chef Community Guidelines

## 2.8.34 (2016-11-10)

**Security Updates**

- [#1462] - Upgraded curl to [v7.51.0](https://github.com/chef/omnibus-software/pull/758). curl is bundled in the omnibus package as a dependency of git.

**Enhancements**

- [#1454] - The `tool-search` API endpoint now has two new parameters: `type` to constrain search to a single type of tool and `order` to select alphabetical-by-name (`name`) or reverse-chronological-by-creation-time (`recently_added`). This was added to support searching for compliance profiles from the `inspec` command line tool (see chef/inspec#1219 and chef/inspec#1255 for more).

**Bug Fixes**

- [#1460] - UI was tweaked for the "Advanced Options" search toggle for small viewports, e.g. mobile. (Thanks, @tristanoneil!)


## 2.8.30 (2016-10-17)

**Fixes & Updates**

- [#1452](https://github.com/chef/supermarket/pull/1452) - fixes a bug in 2.8.29 where downloading a cookbook version would break if the version had only the food critic metric result and not the collaborator metric result included with it.


## 2.8.29 (2016-10-10) (2.8.29)

DO NOT USE!  There is a bug in this release!

**Fixes & Updates**

+ [#1433](https://github.com/chef/supermarket/pull/1433) Refactor quality metrics code
+ [#1443](https://github.com/chef/supermarket/pull/1443) Show Fieri Version and tags from Foodcritic runs

## 2.8.27 (2016-10-03) (2.8.27)

**Security Updates**

+ [#1436](https://github.com/chef/supermarket/pull/1436) Upgrades to OpenSSL 1.0.2j

**Fixes & Updates**

+ [#1426](https://github.com/chef/supermarket/pull/1426) Bumps Berkshelf version

## 2.8.25 (2016-09-13) (2.8.25)

**Security Updates**

- [#1427] Upgrade PostgreSQL from 9.3.6 to 9.3.14 to address [several CVEs](https://github.com/chef/supermarket/pull/1427). We don't believe that Supermarket was particularly susceptible to any of the vulnerabilities, but upgrading makes them a non-issue.
- [#1423] Upgrade OpenSSL from 1.0.1t to 1.0.2h in preparation for [1.0.1's end-of-life](https://www.openssl.org/policies/releasestrat.html). No additional CVEs covered as 1.0.1t was the most up-to-date version for 1.0.1.

**Fixes & Updates**

- [#1414] Added Policyfile as an installation example to the cookbook view.
- [#1425] Set the mouse cursor type to `auto` for most of the web UI so that users would see a cursor style for the thing the cursor is over that is consistent with how most other web sites work. Tip of the hat to [Peter Fern](https://github.com/pdf) for pointing the way 😉 to the fix.

## 2.8.0 (2016-07-05) (2.8.0)

**Updates**

- [#1342] Adds Quality Metrics API
- [#1345] Adds tests for Fieri untarring tarballs
- [#1357] Refactor fieri environmental variables


## 2.8.15 (2016-08-31) (2.8.15)

**Fixes**

- [#1418] Fix for an infinite redirect [#1412] from the Supermarket site when uppercase characters appear in the FQDN - Appeared when no fqdn was given and the install defaulted to the node's hostname which was mixed case.
- [#1415] Address deprecation warnings by changing `node.set` to `node.normal` in cookbooks
- Supermarket now built in a Chef Automate pipeline! Adds a build_cookbook for testing and packaging.

## 2.8.3 (2016-08-22)
- [#1402] Use "Chef" and "chef.io" consistently in links.
- [#1405] Use correct URL for Foodcritic project.
- [#1406] Use consistent pluralization of "collaborator metrics"
- [#1409] Upgrade to Rails 4.2 to address [CVE-2016-6316](https://groups.google.com/forum/#!topic/rubyonrails-security/I-VWr034ouk)

## 2.8.2 (2016-08-03)
- [#1312] Adds sending an email to cookbook followers when a cookbook goes up
  for adoption.
- [#1381] Fixed adding the current owner to collaborators when an admin
  initiates a transfer of ownership.
- [#1382] Fixes reevaluating a cookbook when a collaborator is added.
- [#1386] Fixes the database migration command within omnibus to always have a
  HOME set after an update to rb-readline began requiring a HOME.
- [#1387] Fixes config confusion and inconsistencies by no longer requiring FQDN
  and HOME be set and matching in omnibus config. Only a value for FQDN is
  needed now.
- [#1391] Fixes a fieri callback to handle quality metrics results for cookbooks
  with uppercase letters in their name.
- [#1396] Upgrade Ruby to 2.3.0.
- [#1398] Update README with links and Ruby requirements.

## 2.8.1 (2016-07-25)
- [#1370] Support use of systemd on Ubuntu 16.04
- [#1374] Fix wording for passing collaboration metric
- [#1375] Change fieri_results_endpoint to fieri_supermarket_endpoint
- [#1366] Create the log directory to avoid failures which assume it's created
- [#1371] Fix Fieri's handling of cookbook tarballs with non-dir/file entries

## 2.8.0 (2016-07-05)
- [#1342] Adds Quality Metrics API
- [#1345] Adds tests for Fieri untarring tarballs
- [#1357] Refactor fieri environmental variables

## 2.7.4 (2016-06-29)
- [#1350] Airgap feature flag to disable calls to 3rd parties
- [#1357] Upgrade OpenSSL to v1.0.1t (via omnibus & omnibus-software update)
- [#1358] Upgrade Sidekiq & Sidetiq to resolve a stack too deep error when
  scheduling critique of certain cookbooks

## 2.7.3 (2016-06-22)
- [#1343] Untar things as binary in Fieri

## 2.7.2 (2016-06-15)
- [#1328] Add pop-up to confirm putting a cookbook up for adoption
- [#1338] Fix Quality tab not displaying foodcritic feedback when there are no failures

## 2.7.1 (2016-06-10)
- Same as 2.7.0, increments version number after an error with the build and release of 2.7.0

## 2.7.0 (2016-06-09)
- [#1323] Fix platform search wording
- [#1313] Changes Food Critic tab to Quality tab
- [#1300] Adds option to add the current owner as a collaborator when transferring ownership
- [#1324] Add a guard to supermarket specific ctl commands being run as a supermarket service user
- [#1330] Update nokogiri
- [#1303] Makes Fieri an engine within the Supermarket code base
- [#1331] Removes as-supermarket-user guard from '-ctl test' command

## 2.6.1 (2016-05-31)
- [#1285] Add documentation route and page for guides, tutorials, and documentation
- [#1286] "Recently Updated" cookbooks list now refers to  list of recently shipped new versions
- [#1287] Allow admins to view users' emails
- [#1290] Fix for disappearing browser when clicking a cookbook's changelog tab
- [#1293] Changing supermarket activity stream to report correct user for releases
- [#1306] Do not allow a cookbook version to be destroyed if it is the last version of a cookbook
- [#1320] Remove PR assignment from Curry
- [#1299] Move the cache_path into the omnibus var dir to avoid warnings
- [#1322] Reverts changing paperclip to use path urls

## 2.6.0 (2016-05-04)
- [#1289] Upgrade node things
- [#1292] Schedules in CCLA
- [#1275] Shrink SVGs
- [#1284] Hide Announcements
- [#1281] Make S3 Location Agnostic
- [#1270] Fieri use with on disk cookbooks
- [#1278] Add Ubuntu 1204 to Kitchen
- [#1280] Fix Readme
- [#1279] Updates for publishing licensing information

## 2.5.2 (2016-04-14)
Updates package number in omnibus software definition

## 2.5.1 (2016-04-14)
- [#1252] Update deprecation form text
- [#1253] Refine deprecation form and banner
- [#1255] Bring in omnibus omnibus packager
- [#1260] Fix badges for CodeClimate and InchCI
- [#1261] Update Paperclip
- [#1267] Fix upgrades on RHELish systems
- [#1268] Add license info to omnibus project
- [#1264] Add zLinux platform
- [#1274] Fix Rails console
- [#1273] Add opensuseleap support
- [#1272] Make the readme badges SVGs
- [#1269] Fix seeds with new location of README


## 2.5.0 (2016-03-24)
- [chef/supermarket#1245] Allow cookbook to be deprecated without specifying
  a replacement. (Closes #1223)

## 2.4.2 (2016-03-08)
- [chef/supermarket#1240] Upgrade Rails to 4.1.14.2 to address CVEs
- [chef/omnibus-supermarket#49] Upgrade omnibus install for OpenSSL 1.0.1s update
- [chef/supermarket#1242] Update steps/links to create/login to Chef account

## 2.4.1 (2016-02-26)
- Revert chef/omnibus-supermarket#48 Fix https/http proxy header when https is disabled -
  needs a more comprehensive fix for various https/http scenarios

## 2.4.0 (2016-02-25)
- [chef/supermarket#1220] Turn on Rails Rubocops and update controllers & models
- [chef/supermarket#1222] Add search to Contributors page
- [chef/supermarket#1229] Add supported platform filter to cookbook index API endpoint
  (Thanks, Joel Freedman at Pivotal Sydney!)
- [chef/omnibus-supermarket#48] Fix https/http proxy header when https is disabled

## 2.3.3 (2016-02-03)
- [#1215] Upgrade rspec
- [#1199] Add partner badges
- [#1214] Increase contributors shown per page
- [#1216] Add badges to advanced search for cookbooks
- [#1217] Add rake task to spin up PostgreSQL and Redis in Docker
- [#1218] Fix display of dependencies for cookbook versions
- [#1211] Add Chef and Ohai attributes to cookbook versions
- [#1219] Add Guard to run tests
- [chef/omnibus-supermarket#46] Update omnibus and software for openssl 1.0.1r

## 2.3.2 (2016-01-27)
- [chef/omnibus-supermarket#45] Pin embedded berkshelf to prevent net-ssh upgrade

## 2.3.1 (2016-01-26)
- [1188] Prevent test suite from calling out to 3rd party services.
- [1189] Increase changelog content included in email notifications.
- [1206] Fix omission of PostgreSQL extension requirement in migrations.
- [1205] Fix people and titles disappearing from dashboard on small displays.
- [1162] Increase number of contributors displayed on a page from 10 to 50.
- [1209] Upgrade Nokogiri to address CVE
- [1212] Upgrade Rails to address CVEs

## 2.3.0 (2016-01-08)
- [1196] Add Compliance Profile as a new type of tool
- [1195, 1195] Update ROADMAP items
- [1191] Upgrade Nokogiri
- [omnibus-supermarket#44] Upgrade libxml2 via omnibus-software update

## 2.2.2 (2015-12-23)
- [omnibus-supermarket#42] Fix sitemap permissions
- [omnibus-supermarket#40] Add supermarket-ctl console command
- [omnibus-supermarket#43] Fix broken specs

## 2.2.1 (2015-12-18)
- Same as 2.2.0
- Corrects release error

## 2.2.0 (2015-12-18)
- [1151] Add Collaborator Groups feature to Supermarket
- [1185] Bring Ruby version back to 2.1.x
- [omnibus-supermarket#38] Add documentation for collaborator groups feature
- [omnibus-supermarket#41] Change Ruby to v2.1.8

## 2.1.4-alpha.0 (2015-12-10)
- [1161] Upgrade Ruby to 2.2.3
- [omnibus-supermarket#39] Upgrade embedded Ruby, RubyGems, cacerts and OpenSSL

## 2.1.3-alpha.0 (2015-12-08)
- [1172] Update nokogiri to address CVEs
- [1163] Update README with correct current URLs to GitHub repos and mailing list
- [1163] Configure Travis CI to use container infrastructure
- [1167] Fix Curry's computation of what the GitHub repo webhook callback URL should be in production
- [1173] Update README to have consistent use of `bundle exec`
- [1174] Fix `db/seeds.rb` by providing a default callback URL in development

## 2.1.2-alpha.0 (2015-11-25)
- [1170] - No longer invoke foundation tooltips with user supplied content (High Priority Security Fix)

## 2.1.1-alpha.0 (2015-11-24)
- [1146, 1147] Refactor collaborator processing into a reusable concern
- [1153] Update gems (shoulda-matchers, uglifier, chef, sidekiq) for security vulnerability patches
- [1154] Add bundler-audit to test suite
- [1157] Fix deprecation warnings in test suite
- [1160] Add more detail to error given during dependency version validation
- [omnibus-supermarket#37] Add logrotate to supermarket install to handle nginx logs

## 2.1.0-alpha.0 (2015-10-20)
- [1125] - updates changelog
- [1126] - updates README
- [1134] - updates doc to clarify ICLA vs CCLA
- [1136] - update roadmap
- [1138] - fix signer creation in seeds
- [1143] - update docs for minimum requirements for a Supermarket server
- [1142] - change Time.now to Time.current
- [1140] - Export CLA signatures rake task
- [1144] - Fix Postgresql requirement in README

## 2.0.2-alpha.0 (2015-09-17)
- [1103] Add link to Chef Status page to footer
- [1123] Allow admin users to add collaborators, remove collaborators, and transfer ownership

## 2.0.1-alpha.0 (2015-09-10)
- [1102] Corrects maintainers file
- [1106] Corrects profile links
- [1109] Correct output of noisy spec
- [1105] Correct docs
- [1111] Add simple branding
- [1112] Remove double at in keys help text
- [1114] Correct closing link tag
- [1070] Ensure we set a maintainer only once
- [1118] Fix adoption email url

## 2.0.0-alpha.0 (2015-08-13)
- [1073] Convert owners file to maintainers file
- [1074] Update making an admin user docs
- [1075] Update security vulnerable gems
- [1072] Allow admins to add collaborators
- [1084] remove cookbooks survey
- [1083] Add private key documentatino
- [1077] Add log level docs
- [1085] Add linke to feedback site
- [1079] Remove download counts
- [1078] Add roadmap
- [1087] Fix type on ICLA duplicate signature message
- [1092] Update changelog
- [1089] Remove coveralls
- [1091] Enhance adoption email
- [1095] Add mail instructions
- [1097] Clarify Supermarket Omnibus Instructions
- [1099] Update omnibus to handle no ssl on port 443

## 1.12.1-alpha.0 (2015-08-11)
- Updated Omnibus to handle diabling SSL on port 443

## 1.12.0-alpha.0 (2015-06-23)
- [1067] - Automatically assign maintainers to pull requests
- [1063] - Ability to specify s3 bucket paths

## 1.11.0-alpha.0 (2015-06-18)
- [1066] - remove gitter reference from announcement banner
- [1064] - Be more liberal in our configuration tools config
- [1055] - part #2 of removing cookbook self-deps
- [1054] - Make user admin task
- [21] - updating the Gemfile.lock version of omnibus for an error fix
- [22] - Add supermarket ctl command
- [23] - Support rds for postgres
- [25] - Dhparam Options
- [29] - PostgreSQL Credentials

## 1.10.1-alpha.0 (2015-05-15)
Upping version to account for changes in [omnibus-supermarket](https://github.com/chef/omnibus-supermarket/tree/1.10.0-alpha.0)

These changes include (remember, these changes are on omnibus-supermarket)
- [16] - Update omnibus software versions
- [17] - Fix Postgres configuration typos
- [18] - Updating README to point to the most recent version of a Supermarket setup blog post
- [19] - Make Gravatar feature enabled by default

## 1.10.0-alpha.0 (2015-05-14)
- [1028] - Add advanced search functionality to search for cookbooks based on platform
- [1040] - Fix search bar width
- [1039] - Remove Ruby 2.1.3 from the Gemfile
- [1043] - Prevent the universe endpoint from a cookbook showing itself as a dependency on itself
- [1041] - When ownership is transferred, make the previous owner a collaborator on the cookbook
- [1045] - Add zebra striping to adoptable cookbooks list
- [1044] - Add rake tasks to verify development/test env
- [1047] - Remove obsolete info from the README
- [1038] - Add option to disable Gravatars

## 1.9.0-alpha.0 (2015-04-30)
- [#1027] Close an XSS hole
- [#1029] Add notes about chef server url and dev mode configuration
- [#1031] Cookbooks available for adoption
- [#1032] Fix Custom Chef Oauth2 URL
- [#1033] Add link to survey
- [#1034] Add in documentation for Admin users

## 1.8.0-alpha.0 (2015-04-16)
- [#1020] Temporary urls for private s3 storage
- [#1015] adding in links to Chef corporate legalese in common footer
- [#1023] Remove commas from platform names in seed.rb
- [#1014] correcting OWNERS file to reflect current ownership
- [#1019] Add some platforms and dependencies to seed.rb
- [#1013] Update link to supermarket cookbook in README.md
- [#940] Make log level configurable
- [#1001] Update Chef's office address

## 1.7.0-alpha.0 (2015-03-13)
- Updated omnibus and omnibus-software with bug fixes
- [#1004] Remove incorrect dev environment instructions
- [#995] Fixes for blog links
- [#992] Fix universe endpoint name
- [#988] Documentation improvements
- [#982] Fix mailing lists URL
- [#979] Update README
- [#978] Revise Curry navigation link copy
- [#976] Make destruction message less scary
- [#970] Remove links to old wiki

## 1.6.0-alpha.0 (2015-01-21)
- [#934] Only show source/issues URLs if they're present
- [#936] Add powershell modules and dsc resources to available tool types
- [#937] List which FEATURES are enabled in the health endpoint
- [#942] Add a button for sorting search results by release date
- [#945] Show contributors even if GH is disabled
- [#946] Show code of conduct in the footer
- [#951] Adding changelogs to more Atom feeds
- [#952] Add docs on feature flags to the README
- [#953] Fix error with empty collections in atom feeds
- [#959] Return an error message when processing a corrupted tarball
- [#968] Added AIX platform logo
- [#971] Fix incorrect training URL

## 1.5.0-alpha.0 (2014-12-04)
- Update yanked mixlib-shellout version in Omnibus cookbook
- Fix for OAuth2 URL in Omnibus configuration
- [#928] Update Rails to 4.1.8 (CVE-2014-7829)
- [#925] Fix "Get Chef" link in navigation
- [#923] Fix VCR specs for chef.io
- [#922] Update yanked mixlib-shellout version
- [#919] Change default Chef domain to chef.io
- [#916] Allow empty READMEs
- [#915] Make categories optional
- [#912] Add privacy flag
- [#908] Adoption feature for tools and cookbooks
- [#907] Make robots.txt configurable

## 1.4.0 (2014-11-06)
- [#902] More removal of segment.io
- [#901] Gem updates
- [#900] DRY up full host URL generation

## 1.3.0-alpha.0 (2014-10-30)
- [#898] Make sitemap generation configurable
- [#895] Add URL helpers
- [#893] Gem updates
- [#883] Updates to contribution docs
- [#881] Fixes for specs that would not run independently
- [#880] Update Ruby to 2.1.3
- [#878] Fix post-sign-out URL
- [#877] Fix for missing full host in OmniAuth configuration
- [#875] Update README to point to waffle.io instead of Trello
- [#872] Allow disabling of GitHub features
- [#871] Fix warnings from Factory Girl
- [#870] Cache Bundler dependencies on Travis
- [#869] Gem updates
- [#859] Make more Chef server URLs configurable
- [#858] Ensure cookbook update emails are for the version that was uploaded
- [#857] Correct pluralization when only one user or cookbook is on the site
- [#852] Improve cookbook ownership transfer UI
- [#851] Gem updates
- [#850] Improve highlighting of View Source button
- [#849] Remove timed spec for Universe changes
- [#848] Fix typo in cookbook notification
- [#820] Initial builds of Omnibus packages
- [#773] Parse source and issue URLs from cookbook metadata

## 1.2.0 (2014-10-10)
- [#846] Lazily initialize ROLLOUT

## 1.1.0 (2014-10-09)
- [#831] Make email notifications configurable
- [#834] Update README
- [#837] Cleanup old email notifications
- [#838] Upgrade to Ruby 2.1.3
- [#840] Adjust chat redirects
- [#844] Remove segment.io

# 1.0.0 (2014-10-01)
- Initial 1.0 release
