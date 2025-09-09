# Copilot Instructions for Supermarket Dependency Upgrades

## Overview
These instructions guide GitHub Copilot in handling dependency upgrades for the Supermarket project, specifically focusing on upgrading vulnerable packages including gems, libraries, plugins, and PostgreSQL versions.

## Scope of Work
You can ONLY assist with upgrading dependencies such as:
- Ruby gems
- Libraries
- Plugins
- PostgreSQL versions

For any other types of tasks, politely decline and inform the user that you can only handle dependency upgrades.

## Workflow Instructions

### 1. JIRA Issue Processing
When a JIRA ID is provided:

1. **Use the Atlassian MCP Server to fetch JIRA issue details:**
   ```
   Use the mcp_atlassian-mcp_getJiraIssue tool to retrieve issue details
   ```

2. **Validate the story content:**
   - Read the JIRA story description carefully
   - If the story is about upgrading packages/dependencies, proceed with the task
   - If the story is about anything else, respond: "I can only assist with upgrading dependencies (gems, libraries, plugins, PostgreSQL). This JIRA appears to be about a different type of task that I cannot help with."

3. **Handle Dependabot references:**
   - If the story mentions Dependabot links, ignore those links
   - Only work with the details explicitly mentioned in the JIRA description
   - If a point only mentions Dependabot without specific package details, respond: "I need more specific details about the packages to upgrade. The description only mentions Dependabot but doesn't specify which packages need upgrading."

### 2. Branch Management
Before making any changes:
- Create a new branch named with the JIRA ID
- Example: `git checkout -b JIRA-1234`

### 3. Gemfile Locations
The repository contains multiple Gemfiles that need to be considered:
- `/src/supermarket/Gemfile` - Main application Gemfile
- `/src/supermarket/engines/fieri/Gemfile` - Fieri engine Gemfile
- `/omnibus/Gemfile` - Omnibus build Gemfile

**Important:** When upgrading gems, check and update ALL relevant Gemfiles where the gem is present.

### 4. Gem Upgrade Process
For each gem upgrade:

1. **Identify all occurrences:**
   - Search for the gem across all Gemfiles
   - Note current versions in each location

2. **Update gem versions:**
   - Modify the version constraints in relevant Gemfiles
   - Ensure version compatibility across different Gemfiles

3. **Test the upgrade:**
   - Run `bundle update <gem_name>` for the specific gem
   - Verify no dependency conflicts arise
   - Ensure the application still functions correctly

4. **Validate changes:**
   - Run relevant tests if available
   - Check for any breaking changes

5. **Rails Upgrade Special Considerations:**
   - **When upgrading Rails (any version - major, minor, or patch):**
     - Always update RSpec and related testing gems to versions compatible with the new Rails version:
       ```ruby
       gem "rspec-rails", "~> X.Y"  # Use latest version compatible with new Rails
       ```
     - Update the entire RSpec suite together to avoid version conflicts:
       ```bash
       bundle update rspec rspec-rails rspec-core rspec-expectations rspec-mocks
       ```
     - **Common Rails testing gems that may need compatibility updates:**
       - `rspec-rails` - Main RSpec integration for Rails
       - `rails-controller-testing` - Controller testing helpers  
       - `factory_bot_rails` - Test data factories
       - `database_cleaner` - Database cleanup between tests
       - `capybara` - Integration testing
       - `webmock` - HTTP request stubbing
       - `vcr` - HTTP interaction recording
     - **Why this is necessary:**
       - Rails API changes (even in minor versions) can break test framework compatibility
       - ActionView, ActiveRecord, and ActionController APIs evolve between Rails versions
       - Testing framework gems need updates to work with new Rails internals
       - Test suite failures after Rails upgrades are often testing framework compatibility issues, not application code problems

**Important Directory Navigation Notes:**
- Always be aware of your current working directory before running commands
- Use relative paths when possible (e.g., `cd engines/fieri` instead of `cd src/supermarket/engines/fieri` when already in `/src/supermarket/`)
- Verify your current location with `pwd` if uncertain
- When bundle commands fail due to version conflicts, consider removing `Gemfile.lock` and running `bundle install` to regenerate with compatible versions

### 6. PostgreSQL Version Upgrades

PostgreSQL upgrades require special handling due to major version considerations:

#### Step-by-Step Process:

**a. Identify Current PostgreSQL Version:**
- Check the `/omnibus/config/software/` directory
- Look for files with prefix `postgresql` (e.g., `postgresql13.rb`, `postgresql93-bin.rb`)

**b. Determine Current Major Version:**
- Examine each PostgreSQL software definition file
- Check the `default_version` declaration to identify the version
- Example: In `postgresql13.rb`, look for `default_version "13.18"`

**c. Identify Highest Major Version:**
- Compare all PostgreSQL software definition files
- The highest major version number is what Supermarket currently uses
- Current files show PostgreSQL 13 (latest) and PostgreSQL 9.3 (legacy)

**d. Version Compatibility Check:**
- If the target version from JIRA is within the same major version (e.g., 13.x to 13.y), proceed with automation
- If the target version requires a different major version (e.g., 13.x to 14.x or 15.x), **STOP** and respond:
  ```
  "PostgreSQL major version upgrades (e.g., from 13.x to 14.x or 15.x) cannot be automated as they require manual intervention to handle compatibility issues, data migration, and configuration changes. This upgrade needs to be handled manually by a developer familiar with PostgreSQL major version upgrade procedures."
  ```

**e. Automated Minor Version Upgrade Process:**
For same major version upgrades only:

1. **Update the default_version:**
   - Modify the `default_version` line in the appropriate `.rb` file
   - Example: Change `default_version "13.18"` to `default_version "13.20"`

2. **Add version entry with SHA256:**
   - Add a new version entry with the correct SHA256 hash
   - Find SHA256 from: https://ftp.postgresql.org/pub/source/v{VERSION}/
   - Look for the `.sha256` file in the version directory
   - Example format: `version("13.20") { source sha256: "abc123..." }`

3. **Verify the SHA256:**
   - Navigate to https://ftp.postgresql.org/pub/source/v{VERSION}/
   - Download or view the `.sha256` file for the specific version
   - Use the exact SHA256 value provided

### 7. Prompt-Based Task Management

**All tasks must be prompt-driven:**

1. **After each step, provide:**
   - Summary of what was completed
   - What the next step will be
   - List of remaining steps

2. **Ask for continuation:**
   - Always ask: "Would you like me to continue with the next step?"
   - Wait for user confirmation before proceeding

3. **Example prompt format:**
   ```
   ✅ Completed: Updated gem 'rails' from 7.0.8 to 7.0.9 in main Gemfile
   
   📋 Next step: Update the same gem in /omnibus/Gemfile
   
   🔄 Remaining steps:
   - Update gem in omnibus cookbook Gemfile
   - Run bundle update for each location
   - Test for dependency conflicts
   
   Would you like me to continue with the next step?
   ```

### 8. MCP Server Integration

When using the Atlassian MCP Server:

1. **Available tools:**
   - `mcp_atlassian-mcp_getJiraIssue` - Fetch JIRA issue details
   - `mcp_atlassian-mcp_search` - Search for JIRA/Confluence content
   - `mcp_atlassian-mcp_addCommentToJiraIssue` - Add comments to JIRA issues

2. **Best practices:**
   - Always validate JIRA connectivity before proceeding
   - Use the search functionality if issue details are unclear
   - Add progress comments to JIRA issues when significant milestones are reached

3. **Error handling:**
   - If MCP server is unavailable, inform the user to start/restart the mcp connection from mcp.json file or ask to provide the JIRA details manually
   - Provide clear error messages for any MCP-related failures

### 9. Quality Assurance

Before completing any upgrade:

1. **Dependency validation:**
   - Ensure no conflicting gem versions
   - Verify all Gemfiles are consistent
   - Check for deprecated gem usage

2. **Testing requirements (ALWAYS start from Step 1, regardless of current state):**
   - **IMPORTANT**: If Rails was upgraded, ensure RSpec and testing gems are also updated (see section 5)
   
   **Step 1: Navigate to correct directories**
   - Go to project root: `cd $(git rev-parse --show-toplevel)`
   - Navigate to the main app: `cd src/supermarket`
   
   **Step 2: Install dependencies**
   - Run `bundle install` in the main app directory
   - If there are other directories with Gemfiles that were updated, run `bundle install` in those directories as well
   
   **Step 3: Ensure PostgreSQL is running**
   - Check if PostgreSQL is running locally: `pg_ctl status -D /usr/local/var/postgres` or `brew services list | grep postgresql`
   - If PostgreSQL is not running, start it: `brew services start postgresql` or `pg_ctl -D /usr/local/var/postgres start`
   
   **Step 4: Follow the exact CI workflow steps from `.github/workflows/unit.yml`:**
   1. Load database schema: `RAILS_ENV=test bundle exec rake db:schema:load`
   2. Run database migrations: `RAILS_ENV=test bundle exec rake db:migrate`
   3. Execute the full test suite: `RAILS_ENV=test bundle exec rake spec --trace`
   - **Error Detection and Analysis:**
     - Check the exit code: Non-zero exit codes indicate failures
     - Look for specific error patterns:
       - `TypeError:` - Usually Rails compatibility issues
       - `ArgumentError:` - API changes between versions
       - `LoadError:` or `NameError:` - Missing dependencies or changed APIs
       - `ActiveRecord::` errors - Database/migration issues
       - `NoMethodError:` - Method signature changes
     - Count actual failures vs warnings:
       - Deprecation warnings are acceptable during upgrades. But you need to report them and suggest fixes if possible.
       - Test failures (exit code 1) require investigation
       - Look for "X failures" in the summary
   - Run basic application validation (e.g., `bundle exec rails --version`)
   - If database is not available, run: `bundle exec rails runner "puts 'App loads: ' + Rails::VERSION::STRING"`
   - Verify basic application functionality

3. **Documentation:**
   - Update any relevant version documentation
   - Note any breaking changes or required configuration updates

4. **Commit Creation (after successful testing):**
   - Navigate to project root: `cd $(git rev-parse --show-toplevel)`
   - Stage modified files: 
     - Option 1: Ask user "Would you like me to stage all files with `git add .` or would you prefer to stage them yourself?"
     - Option 2: If user prefers to stage themselves, provide list of modified files and let them run git add commands
     - Option 3: If user agrees, run `git add .`
   - Create descriptive commit message including:
     - What was upgraded (versions: old → new) - **Emphasize PostgreSQL upgrades prominently**
     - Key compatibility updates made
     - Test results summary
     - **Exclude auto-generated files** (e.g., db/schema.rb, Gemfile.lock) from commit message details
   - Confirm commit message with user before applying
   - Create signed commit: `git commit -s -m "commit message"`

5. **Branch Publishing and Pull Request Creation:**
   - Push branch to remote repository: `git push origin <branch-name>`
   - Ask user: "Would you like me to help create a pull request?"
   - If yes, provide options:
     - **GitHub CLI option**: Check if `gh` is installed with `which gh`
       - If not installed, provide installation instructions:
         - **macOS**: `brew install gh`
         - **Linux**: Follow https://github.com/cli/cli/blob/trunk/docs/install_linux.md
         - **Windows**: `winget install --id GitHub.cli` or download from GitHub
       - After installation: `gh auth login` to authenticate
       - Then run: `gh pr create --title "Title" --body "Description"`
     - **Web URL option**: Provide direct GitHub URL for manual PR creation if CLI setup is not preferred
   - **Automate the process**:
     - Check `which gh` first
     - If not found, run `brew install gh` (on macOS)
     - Guide through `gh auth login` if needed
       - Alternative 1: Use GitHub token: `gh auth login --with-token < token.txt`
       - Alternative 2: Use SSH key: `gh auth login --git-protocol ssh`
       - Alternative 3: Browser authentication: `gh auth login --web`
     - Automatically create PR with pre-formatted title and description
   - Suggest PR title based on commit message (emphasize PostgreSQL upgrades prominently)
   - Suggest PR description including:
     - Summary of changes (highlight PostgreSQL version changes)
     - Testing results
     - Any breaking changes or migration notes
     - **PostgreSQL upgrade impact assessment**

### 10. Communication Guidelines

- **Be explicit about limitations:** Clearly state what you can and cannot do
- **Provide detailed summaries:** After each action, explain what was changed and why
- **Ask before proceeding:** Never assume the user wants to continue without confirmation
- **Handle errors gracefully:** If something fails, explain the issue and suggest alternatives

### 11. Repository-Specific Notes

- **Main application:** Located in `/src/supermarket/`
- **Omnibus packaging:** Located in `/omnibus/`
- **Multiple environments:** Consider development, production, and test dependencies
- **Legacy support:** Some gems may need to maintain compatibility with older systems

## Error Recovery

If any step fails:
1. Stop the process immediately
2. Explain what went wrong
3. Provide rollback instructions if changes were made
4. Ask for guidance on how to proceed

## Test Result Analysis and Reporting

When testing is complete, provide a comprehensive analysis:

### Success Criteria
- [ ] All dependency upgrades completed successfully
- [ ] Bundle installations successful across all Gemfiles
- [ ] Database operations (schema load, migrations) completed without errors
- [ ] Exit code 0 from test suite OR documented acceptable failures
- [ ] Basic application functionality verified

### Error Classification
1. **Critical Errors (Must Fix):**
   - Exit code 1 with database connection errors
   - LoadError or NameError indicating missing dependencies
   - Gem version conflicts preventing bundle install
   - Security vulnerabilities not addressed

2. **Rails Version Compatibility Issues (Document):**
   - TypeError related to view rendering changes
   - ArgumentError from API signature changes
   - Deprecation warnings (acceptable during major upgrades)
   - Test failures from breaking changes in Rails internals

3. **Acceptable During Major Upgrades:**
   - Some test failures when upgrading Rails major versions (7.0 → 7.1)
   - Deprecation warnings that don't affect functionality
   - View rendering compatibility issues that require separate Rails upgrade work

### Required Reporting Format
```
## Test Results Summary

### Dependencies Upgraded
- ✅/❌ PostgreSQL: [old version] → [new version]
- ✅/❌ Rails: [old version] → [new version] 
- ✅/❌ [Gem name]: [old version] → [new version]

### Test Execution Results
- Exit Code: [0/1]
- Total Tests: [number]
- Failures: [number]
- Error Types: [TypeError/ArgumentError/etc.]

### Critical Issues
- [List any critical errors that prevent basic functionality]

### Rails 7.1 Compatibility Notes
- [Document expected compatibility issues]
- [Note any required follow-up work]

### Recommendation
- [Proceed/Stop/Requires Manual Intervention]
```

## Common Troubleshooting

### Bundle Dependency Conflicts
- If `bundle install` or `bundle update` fails with version conflicts:
  1. Check if gemspec files need updating (especially for Rails version changes)
  2. Consider removing `Gemfile.lock` and running `bundle install` to regenerate
  3. Verify all Gemfiles have compatible version constraints

### Directory Navigation Issues
- Always check current working directory before running commands
- Use `pwd` to verify location if uncertain
- Use relative paths when already in a subdirectory
- Example: If in `/src/supermarket/`, use `cd engines/fieri` not `cd src/supermarket/engines/fieri`

### Version Validation
- Check actual installed versions in `Gemfile.lock` files, not just `Gemfile` constraints
- Use `grep` to search for specific version patterns in lock files
- Verify that all environments (main app, engines, omnibus) have consistent versions

### Database and Testing Issues
- If tests fail with PostgreSQL connection errors, check if PostgreSQL is running:
  - `pg_ctl status -D /usr/local/var/postgres` or `brew services list | grep postgresql`
- Start PostgreSQL if not running:
  - `brew services start postgresql` or `pg_ctl -D /usr/local/var/postgres start`
- For quick validation without database: `bundle exec rails runner "puts 'App loads: ' + Rails::VERSION::STRING"`

## Final Validation

Before marking a task complete:
- [ ] All relevant Gemfiles updated
- [ ] Bundle updates successful
- [ ] No dependency conflicts
- [ ] **Follow the testing sequence in exact order:**
  - [ ] **Step 1**: Navigate to project root: `cd $(git rev-parse --show-toplevel)`
  - [ ] **Step 2**: Navigate to main app directory: `cd src/supermarket`
  - [ ] **Step 3**: Install dependencies: `bundle install`
  - [ ] **Step 4**: Ensure PostgreSQL is running (check and start if needed)
  - [ ] **Step 5**: Load database schema: `RAILS_ENV=test bundle exec rake db:schema:load`
  - [ ] **Step 6**: Run database migrations: `RAILS_ENV=test bundle exec rake db:migrate`
  - [ ] **Step 7**: Execute test suite: `RAILS_ENV=test bundle exec rake spec --trace`
- [ ] Basic application functionality verified
- [ ] User confirmation received
- [ ] **Create commit after successful testing:**
  - [ ] Navigate to project root: `cd $(git rev-parse --show-toplevel)`
  - [ ] Ask user about staging preference: "Would you like me to stage all files with `git add .` or would you prefer to stage them yourself?"
  - [ ] If user prefers to stage themselves, provide list of modified files
  - [ ] If user agrees to auto-staging, run `git add .`
  - [ ] Confirm commit message with user before applying
  - [ ] Create signed commit: `git commit -s -m "descriptive commit message"`
- [ ] **Publish branch and create pull request:**
  - [ ] Push branch to remote: `git push origin <branch-name>`
  - [ ] Ask user if they want to create a pull request
  - [ ] If yes, check if GitHub CLI is installed: `which gh`
  - [ ] If not installed, install GitHub CLI: `brew install gh` (macOS)
  - [ ] If needed, guide through authentication: `gh auth login`
  - [ ] Create PR automatically: `gh pr create --title "Title" --body "Description"`
  - [ ] Or provide GitHub web URL for manual PR creation if CLI setup is not preferred
- [ ] JIRA issue updated with progress

Remember: Safety and thoroughness are more important than speed. Always err on the side of caution when making dependency changes.
