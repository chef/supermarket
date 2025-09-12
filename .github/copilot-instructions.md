# Copilot Instructions for Supermarket Dependency Upgrades

## Overview
These instructions guide GitHub Copilot in handling dependency upgrades for the Supermarket project, specifically focusing on upgrading vulnerable packages including gems, libraries, plugins, and PostgreSQL versions.

## Scope of Work
You can assist with:
- **General questions and miscellaneous topics** related to the codebase, development practices, technical topics, tools, and any other general guidance
- **JIRA stories specifically about upgrading dependencies in the Supermarket project** such as:
  - Ruby gems
  - Libraries
  - Plugins
  - PostgreSQL versions

**Important:** When a JIRA ID is provided, you can ONLY help if the JIRA story is about the Supermarket project AND about dependency/package upgrades. For JIRA stories about other types of tasks or other projects, politely decline and inform the user that you can only handle JIRA stories related to dependency upgrades in the Supermarket project, but you're happy to help with general questions and miscellaneous topics.

## Workflow Instructions

### 1. JIRA Issue Processing
When a JIRA ID is provided:

1. **Use the Atlassian MCP Server to fetch JIRA issue details:**
   ```
   Use the mcp_atlassian-mcp_getJiraIssue tool to retrieve issue details
   ```

2. **Validate the story content:**
   - Read the JIRA story description carefully
   - **First check if the story is related to the Supermarket project**
   - If the story is NOT about Supermarket, respond: "I can only assist with JIRA stories about upgrading dependencies in the Supermarket project. This JIRA appears to be about a different project. However, I'm happy to help with general questions, miscellaneous topics, or guidance about the Supermarket codebase."
   - If the story IS about Supermarket but NOT about upgrading packages/dependencies, respond: "I can only assist with JIRA stories about upgrading dependencies (gems, libraries, plugins, PostgreSQL) in the Supermarket project. This JIRA appears to be about a different type of task that I cannot help with. However, I'm happy to help with general questions, miscellaneous topics, or guidance about the Supermarket codebase."
   - Only if the story is about Supermarket AND about upgrading packages/dependencies, proceed with the task

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

**⚠️ CRITICAL FOR RAILS UPGRADES:**
If Rails is being upgraded (any version change), you MUST update the testing framework immediately after updating Rails but BEFORE running the test suite. See section 5 for detailed Rails upgrade procedures including mandatory RSpec updates.

5. **Rails Upgrade Special Considerations:**
   - **When upgrading Rails (any version - major, minor, or patch):**
     - **MANDATORY**: After updating Rails version, check for updates for RSpec and related testing framework gems in this project and upgrade them to a version compatible with the new Rails version
     - **Process:**
       1. **Check current gem versions:**
          ```bash
          bundle list | grep -E "(rspec|database_cleaner|capybara|webmock|factory_bot|rails-controller-testing)"
          ```
       2. **Check for available updates compatible with new Rails version:**
          ```bash
          bundle outdated rspec rspec-rails database_cleaner capybara webmock factory_bot_rails rails-controller-testing
          ```
       3. **Update testing framework gems:**
          ```bash
          # Main application
          cd src/supermarket
          bundle update rspec rspec-rails rspec-core rspec-expectations rspec-mocks rails-controller-testing factory_bot_rails capybara webmock database_cleaner
          
          # Fieri engine
          cd engines/fieri
          bundle update rspec-rails webmock
          ```
       4. **Verify compatibility before running full test suite:**
          ```bash
          RAILS_ENV=test bundle exec rails runner "puts 'Rails ' + Rails::VERSION::STRING + ' loads successfully with updated testing gems'"
          ```
     - **Key testing gems that must be compatible with Rails version:**
       - `rspec-rails` - Main RSpec integration for Rails
       - `database_cleaner` - Database cleanup between tests  
       - `rails-controller-testing` - Controller testing helpers
       - `factory_bot_rails` - Test data factories
       - `capybara` - Integration testing
       - `webmock` - HTTP request stubbing
     - **Why this is necessary:**
       - Rails API changes can break test framework compatibility
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
   - `mcp_atlassian-mcp_getAccessibleAtlassianResources` - Get cloud IDs and available resources

2. **Cloud ID Discovery (Critical):**
   - **Never assume cloud ID format** - Don't use organization names like "chef" as cloud IDs
   - **Always use `getAccessibleAtlassianResources` first** to get the correct cloud ID:
     ```
     Use mcp_atlassian-mcp_getAccessibleAtlassianResources to get available cloud IDs
     ```
   - **Cloud IDs are UUIDs** like `88f3d16e-26e6-4cdf-a16d-b9d8f528c074`, not organization names
   - **Common error pattern:** `"Failed to fetch cloud ID for: chef. Error: Input does not look like a valid domain or URL"`
   - **Solution:** Extract the correct UUID cloud ID from the `getAccessibleAtlassianResources` response

3. **Best practices:**
   - Always validate JIRA connectivity before proceeding
   - Use the search functionality if issue details are unclear
   - Add progress comments to JIRA issues when significant milestones are reached

4. **Error handling:**
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
   
   **Step 5: Test Fieri engine if updated:**
   - Navigate to Fieri engine: `cd engines/fieri`
   - Install dependencies: `bundle install`
   - Run Fieri tests: `RAILS_ENV=test bundle exec rake spec --trace`
   - Return to main app: `cd ../..`
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
     - **Check all commits from main branch**: Use `git log --oneline main..HEAD` to get comprehensive view of all changes
     - Automatically create PR with pre-formatted title and description based on complete commit history
   - Suggest PR title based on all commits in branch (emphasize PostgreSQL upgrades prominently)
   - Suggest PR description including:
     - Summary of all changes from main branch (highlight PostgreSQL version changes)
     - Complete list of dependency upgrades with version changes
     - Any breaking changes or migration notes
     - **PostgreSQL upgrade impact assessment**
6. **Add comment to JIRA story (after successful PR creation):**
   - **Immediately after PR creation**, use the Atlassian MCP Server to add a comment to the original JIRA story
   - Comment format:
     ```markdown
     🔗 **Pull Request Created**
     
     **Repository:** chef/supermarket
     **Branch:** <branch-name>
     **PR:** [#<pr-number> - <pr-title>](<pr-url>)
     
     **Summary of Changes:**
     - <brief-summary-of-dependency-upgrades>
     - <additional-changes>
     - <other-updates>
     
     **Status:** Ready for review
     
     _Automatically created from VS Code dependency upgrade workflow_
     ```
   - **Implementation using MCP Atlassian server:**
     - Use `mcp_atlassian-mcp_addCommentToJiraIssue` tool
     - Extract JIRA ID from branch name or commit message
     - Format comment in Markdown as shown above
   - **Error handling:** If JIRA comment fails, continue with workflow but notify user that manual comment addition may be needed

7. **Buildkite Build Automation (after JIRA comment):**
   - **Step 1: Verify GitHub Checks Status**
     - **Before triggering any Buildkite build**, always check GitHub Actions status first
     - Use command: `gh pr checks <pr-number>` to verify all checks
     - **Required status for proceeding:**
       - ✅ The output must show "All checks were successful"
       - ❌ **0 failing checks**
       - ⏸️ **0 pending checks** (wait if any are still running)
     - **If checks are failing or pending:**
       - Inform user about failing/pending checks
       - Provide the failing check names and URLs from the command output
       - **Do not proceed** with Buildkite build until all checks pass
       - Suggest user fix issues and re-run checks if needed

   - **Step 2: Prompt User for Buildkite Build (only after all GitHub checks pass)**
     - **After confirming all GitHub checks are successful using `gh pr checks`**, ask the user: "All GitHub checks are successful! Would you like me to trigger a Buildkite build for this branch to validate the changes?"
   - **Provide a clear confirmation prompt** with context:
     ```
     🚀 **Trigger Buildkite Build?**
     
     ✅ GitHub Checks Status: All checks successful
     Pipeline: chef-supermarket-main-omnibus-adhoc
     Branch: <branch-name>
     Commit: <commit-sha>
     
     This will start an ad-hoc build to validate your dependency upgrades.
     
     [Yes, trigger build] [No, skip build]
     ```
   - **Only proceed if user confirms "Yes"**
   
   - **Note about API vs MCP Server:**
     - While Buildkite MCP server is available for read operations, we use direct API for build triggering
     - This is because the MCP server doesn't support `ignore_pipeline_branch_filters` parameter
     - Direct API allows ad-hoc builds on non-default branches which is essential for dependency upgrade workflow
   - **If user confirms**, use direct Buildkite API to trigger the build:
     
     **Step 1: Verify API Token and Permissions**
     - Check that the Buildkite API token has the required permissions:
       - ✅ `write_builds` - **Required** for triggering builds
       - ✅ `read_builds` - For checking build status
       - ✅ `read_pipelines` - For verifying pipeline access
       - ✅ `read_organizations` - For organization access
     - Verify token permissions: `curl -H "Authorization: Bearer <token>" https://api.buildkite.com/v2/access-token`
     - The response should include `"write_builds"` in the scopes array
     
     **Step 2: Setup and Export Environment Variables**
     - **First, check if Buildkite API token is available:**
       ```bash
       env | grep -i buildkite || echo "No Buildkite environment variables found"
       ```
     - **If no Buildkite environment variables are found, set up the token:**
       - Prompt user for their Buildkite API token (if not provided, guide them to create one)
       - Determine the user's shell configuration file:
         ```bash
         SHELL_CONFIG_FILE=""
         if [[ "$SHELL" == */zsh ]]; then
           SHELL_CONFIG_FILE="$HOME/.zshrc"
         elif [[ "$SHELL" == */bash ]]; then
           SHELL_CONFIG_FILE="$HOME/.bashrc"
         else
           echo "Unsupported shell. Please add the environment variable manually."
           exit 1
         fi
         ```
       - Add the API token to the shell configuration file:
         ```bash
         echo "" >> "$SHELL_CONFIG_FILE"
         echo "# Buildkite API Configuration" >> "$SHELL_CONFIG_FILE"
         echo "export BUILDKITE_API_TOKEN=\"your-api-token-here\"" >> "$SHELL_CONFIG_FILE"
         echo "export BUILDKITE_ORG=\"chef\"" >> "$SHELL_CONFIG_FILE"
         ```
       - Reload the shell configuration:
         ```bash
         source "$SHELL_CONFIG_FILE"
         ```
       - Verify the token is now available:
         ```bash
         echo "BUILDKITE_API_TOKEN is set: ${BUILDKITE_API_TOKEN:+YES}"
         ```
     - **If token is already available, export the organization:**
       ```bash
       export BUILDKITE_ORG="chef"
       ```
     - **API Token Requirements:**
       - If user doesn't have a token, guide them to create one at: https://buildkite.com/user/api-access-tokens
       - Required scopes: `write_builds`, `read_builds`, `read_pipelines`, `read_organizations`
       - Must have access to the `chef` organization
     
     **Step 3: Trigger Build via Direct API Call**
     - Use direct curl command to trigger the build with branch filter bypass:
       ```bash
       curl -X POST \
         -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
         -H "Content-Type: application/json" \
         -d '{"commit": "<current-commit-sha>", "branch": "<branch-name>", "message": "Ad-hoc build for <JIRA-ID> - Security upgrade validation", "ignore_pipeline_branch_filters": true}' \
         "https://api.buildkite.com/v2/organizations/$BUILDKITE_ORG/pipelines/chef-supermarket-main-omnibus-adhoc/builds" | jq -r '"Build #" + (.number | tostring) + " triggered: " + .web_url'
       ```
     - **Important:** The `ignore_pipeline_branch_filters: true` parameter is crucial for ad-hoc builds on non-default branches
     - **Why this approach works better:**
       - Single command execution (no complex variable assignments)
       - Immediate JSON parsing with `jq` pipe
       - No control character cleanup needed
       - Reliable terminal execution
       - Direct output of build number and URL
   - **On successful build trigger:**
     - The command will output: "Build #<number> triggered: <url>"
     - Extract build number and URL from this output for PR comment
     - Display build details: Build number, web URL from command output
     - Example: "✅ Build #729 triggered successfully! Monitor progress at: https://buildkite.com/chef/chef-supermarket-main-omnibus-adhoc/builds/729"
     - **Add comment to the PR with build information:**
       - Use GitHub API or GitHub CLI to add a comment
       - Extract the build number and URL from the command output
       - Comment format:
         ```markdown
         🚀 **Buildkite Build Triggered**
         
         **Pipeline:** chef-supermarket-main-omnibus-adhoc
         **Build:** [#<build-number>](<build-url>)
         **Status:** Running
         **Branch:** <branch-name>
         **Commit:** <commit-sha>
         
         📊 **Monitor Progress:** [Build #<build-number>](<build-url>)
         
         _Automatically triggered from VS Code dependency upgrade workflow_
         ```
       - **Important:** Use the build number and URL from the curl command output
       - **Implementation options:**
         - **GitHub CLI**: `gh pr comment <pr-number> --body "<comment-text>"`
         - **GitHub API**: `curl -X POST -H "Authorization: token <github-token>" -d '{"body":"<comment-text>"}' https://api.github.com/repos/chef/supermarket/issues/<pr-number>/comments`
       - **Error handling:** If PR comment fails, continue with build trigger but notify user that manual comment addition may be needed
   - **On build trigger failure:**
     - Display the error message from API response
     - Provide the manual steps to trigger the build through Buildkite web UI
     - Suggest checking API token permissions if needed
   - **Prerequisites for this automation:**
     - Buildkite API token with `write_builds` scope (will be automatically configured in shell config if not present)
     - Network access to Buildkite API
     - `jq` command available for JSON parsing (install with `brew install jq` on macOS)
     - Shell configuration file access (`.zshrc` for zsh or `.bashrc` for bash)

### 8. Communication Guidelines

- **Be explicit about limitations:** Clearly state what you can and cannot do
- **Provide detailed summaries:** After each action, explain what was changed and why
- **Ask before proceeding:** Never assume the user wants to continue without confirmation
- **Handle errors gracefully:** If something fails, explain the issue and suggest alternatives

### 9. Repository-Specific Notes

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

### Buildkite API and JSON Parsing Issues
- **Recommended Approach:** Use the simple single-command approach that pipes directly to `jq`:
  ```bash
  curl -X POST ... | jq -r '"Build #" + (.number | tostring) + " triggered: " + .web_url'
  ```
- **Why the simple approach works better:**
  - No complex variable assignments that can fail in terminal
  - Direct JSON parsing eliminates control character issues
  - Single command execution is more reliable
  - Immediate output of build number and URL

- **If using the legacy multi-variable approach (not recommended):**
  - **Control Characters in API Responses:** Buildkite API responses may contain control characters that break `jq` parsing
    - **Error:** `jq: parse error: Invalid string: control characters from U+0000 through U+001F must be escaped`
    - **Solution:** Clean the response before parsing:
      ```bash
      CLEAN_RESPONSE=$(echo "$BUILD_RESPONSE" | tr -d '\000-\037' | tr -d '\177')
      BUILD_NUMBER=$(echo "$CLEAN_RESPONSE" | jq -r '.number' 2>/dev/null)
      ```
  - **Empty BUILD_RESPONSE:** If the curl command fails or returns empty response:
    - Check Buildkite API token permissions (must include `write_builds`)
    - Verify network connectivity to api.buildkite.com
    - Ensure organization name is correct (`chef`)
- **jq Command Not Found:** Install jq if not available:
  - **macOS:** `brew install jq`
  - **Linux:** `apt-get install jq` or `yum install jq`

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
