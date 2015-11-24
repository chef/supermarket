# Supermarket Changelog
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
