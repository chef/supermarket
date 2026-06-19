# developer instructions for building and running tests locally
These instructions show how to use CoPilot to identify CVEs in one or more components, propose a fix version, rebundle and retest to make sure it is "safe" and the application still works.  Typically this takes only safe version bumps (2.2.1 to 2.2.latest instead of 2.4 or 3.x which might break code).  

To-do: create the PR for approval in GitHub with all documentation needed, and close the ticket in Jira.

To-do: upgrade to at least Ruby 3.3 (March 2027 EOL)

## Linux / MacOS
### find and update deps
Copilot prompt: can you scan for all active Ruby rack critical and high vulnerabilities and determine the fix version I should update to?

===
Your current lock: rack 2.2.20 | Latest 2.2.x: rack 2.2.23

Here's the full vulnerability scan against the 2.2.x series:

🚨 OPEN — Not fixed in 2.2.20 (need 2.2.23)
CVE	CVSS	Severity	Description	Fixed in
CVE-2026-22860	7.5	High	Directory traversal via Rack::Directory prefix match	~> 2.2.22
CVE-2026-34785	7.5	High	Rack::Static prefix match exposes unintended files	~> 2.2.23
CVE-2026-34829	7.5	High	Unbounded chunked multipart upload exhausts disk (DoS)	~> 2.2.23
CVE-2026-25500	5.4	Medium	Stored XSS in Rack::Directory via javascript: filenames	~> 2.2.22
CVE-2026-34830	5.9	Medium	Rack::Sendfile regex injection → unauthorized file access	~> 2.2.23
CVE-2026-34230	5.3	Medium	Quadratic CPU in Rack::Deflater via Accept-Encoding wildcards	~> 2.2.23
CVE-2026-34763	5.3	Medium	Full filesystem path exposed in Rack::Directory listing	~> 2.2.23
CVE-2026-34786	5.3	Medium	Rack::Static security header bypass via URL-encoded paths	~> 2.2.23
CVE-2026-34826	5.3	Medium	Byte range DoS via many overlapping Range: values	~> 2.2.23
CVE-2026-34831	4.8	Medium	Content-Length mismatch → response desync	~> 2.2.23
CVE-2026-26961	3.7	Low	Multipart boundary WAF bypass	~> 2.2.23
✅ Already fixed in 2.2.20
CVE-2025-61770/71/72 (High, DoS), CVE-2025-61919 (High, DoS), CVE-2025-61780 (Medium, info-disclosure), CVE-2025-59830 (High), CVE-2025-46727 (High), CVE-2025-27610 (High, LFI), CVE-2025-27111/25184 (Medium, log injection), CVE-2025-32441 (Medium)

✅ Not applicable to rack 2.x
CVE-2024-39316, CVE-2025-49007, CVE-2026-26962, CVE-2026-32762, CVE-2026-34827, CVE-2026-34835

→ Fix: update to rack 2.2.23 (the current latest in the 2.x stream, released April 1, 2026). This closes all 11 open vulnerabilities including the 3 High-severity ones.
===

### build the rails app
CoPilot promprt: "in a safe branch, perform the rack update, rebuild and list steps to retest the application"

The current version is in the gemfile or gemfile.lock (if previously built).  So, let Copilot update the gemfile and then bundle update
```
cd src\supermarket
bundle update rack
```

Then start the database
```
cd src/supermarket
docker-compose up -d
```

### retest locally
```
# 1. Switch to correct Ruby
rbenv local 3.1.2   # or: rvm use 3.1.2

# 2. Install dependencies (will now resolve correctly)
cd src/supermarket
bundle install

# 3. Start backing services (Postgres + Redis)
docker-compose up -d db cache

# 4. Set up test database
RAILS_ENV=test bundle exec rake db:schema:load
RAILS_ENV=test bundle exec rake db:migrate

# 5. Run the full test suite
RAILS_ENV=test bundle exec rake spec

# 6. Also test Fieri engine
cd engines/fieri
bundle install
RAILS_ENV=test bundle exec rake spec
cd ../..
```

## Running the containers

### 1. Start backing services (Postgres + Redis)
```
docker-compose up -d db cache
```

### 2. Set up test database
```
docker run --rm --network host \
  -e DATABASE_URL=postgres://localhost/supermarket_test \
  supermarket-test -c "bundle exec rake db:schema:load"

docker run --rm --network host \
  -e DATABASE_URL=postgres://localhost/supermarket_test \
  supermarket-test -c "bundle exec rake db:migrate"
```

### 3. Run the full test suite
```
docker run --rm --network host \
  -e RAILS_ENV=test \
  -e DATABASE_URL=postgres://localhost/supermarket_test \
  -e REDIS_URL=redis://localhost:6379 \
  supermarket-test -c "bundle exec rake spec"
```

## Run the containers from build using Task(file)
### Build the Docker image (like "make")
```
task build
```
### Start everything (db + cache + app) in the background
```
task up
```

### Run the full test suite (waits for db/cache health, then runs specs)
```
task test
```
#### or shorthand:
```
task spec
```

### Other helpers
```
task down     # stop + remove volumes
task logs     # tail all logs
task ps       # show service status
task clean    # stop + remove volumes + delete image
```