# Supermarket Changelog

<!-- latest_release -->
<!-- latest_release -->

<!-- release_rollup -->
<!-- release_rollup -->

<!-- latest_stable_release -->
<!-- latest_stable_release -->

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
