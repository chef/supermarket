# Technical Basis Release Notes Skill

## Purpose
Generate release notes documentation that defines the technical basis for a new product version, including language frameworks, dependencies, infrastructure versions, and component details.

## Output Components

### 1. Language Frameworks & Libraries
Document primary language runtime and major framework versions with bundled components:

**Example Format:**
- Ruby 3.1.2 with bundled libraries: uri, resolv/net-dns
- Rails 7.1.5.2 with major bundled components: actionmailer, actionpack, actiontext, activestorage, activesupport

### 2. Current Component Versions

Always determine the current version of these from source references, and always include this version in the release notes for every item here (they are the technical basis for the release, so they must be included in the release notes):

#### Rails Framework Stack (7.1.5.2)
- actionmailer: 7.1.5.2
- actionpack: 7.1.5.2
- actiontext: 7.1.5.2
- activestorage: 7.1.5.2
- activesupport: 7.1.5.2

#### Critical Dependencies
- bundler: 2.3.7
- cgi: 0.5.0
- fugit: 1.5.3
- globalid: 1.2.1
- jmespath: 1.6.2
- kramdown: 2.5.1
- net-imap: 0.5.10
- nokogiri: 1.18.9
- puma: 5.6.8
- rack: 2.2.23
- rails-html-sanitizer: 1.6.2
- rdoc: 6.14.2
- redcarpet: 3.5.1
- rexml: 3.4.0
- rubyzip: 2.3.2
- stringio: 3.1.7
- time: 0.3.0
- tzinfo: (version TBD)

### 3. Security Infrastructure
- OpenSSL: 3.2.4 with FIPS 3.1.2 (defined in supermarket.rb)
- dnsmasq: N/A

### 4. Web Server & Proxy
- nginx: 1.27 (via OpenResty 1.27.1.2 in omnibus/config/software/supermarket.rb)

### 5. Chef Habitat Packages

| pkg_origin | pkg_name | pkg_version | stable_bldr_url | pkg_deps |
|---|---|---|---|---|
| chef | supermarket-nginx | 1.19.3.1 | https://bldr.habitat.sh/#/pkgs/chef/supermarket-nginx/1.19.3.1 | core/openresty |
| chef | supermarket-postgresql | 9.6.21 | https://bldr.habitat.sh/#/pkgs/chef/supermarket-postgresql/9.6.21 | core/postgresql/9.6.21, core/busybox-static |
| chef | supermarket-redis | 4.0.14 | https://bldr.habitat.sh/#/pkgs/chef/supermarket-redis/4.0.14 | core/redis |

### 6. NPM Dependencies (CVE Risk Assessment)
Reference `packages-lock.json` for frequent CVE offenders including:
- brace-expansion
- minimatch
- pip

### 7. Bundled Tools
List command-line utilities bundled via scripts or Dockerfile (git, curl, etc.)

### 8. Release Notes Output Format

Generate release notes document containing:

1. **Technical Basis Section Header** - Define the version and technical foundation
2. **Language & Framework Stack** - Runtime and major framework versions with bundled components
3. **Component Versions Table** - All pinned dependencies with their versions
4. **Infrastructure Versions** - Security, web server, and proxy configurations
5. **Chef Habitat Packages Table** - Infrastructure components (nginx, postgresql, redis, etc.)
6. **NPM Risk Assessment** - Known CVE-prone packages requiring monitoring
7. **Bundled Utilities** - Command-line tools included in distribution

The output should reference internal configuration files without including their full paths in the public release notes, maintaining clear separation between:
- **Public Release Notes**: Customer-facing documentation
- **Internal Reference Guide**: Development team documentation of source files

## Internal Reference Files
- `supermarket.rb` - OpenSSL/FIPS configuration
- `omnibus/config/software/supermarket.rb` - nginx/OpenResty version
- `packages-lock.json` - npm dependencies and CVE tracking
- Habitat plan.sh files for pkg_origin/pkg_name/pkg_version resolution