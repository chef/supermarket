# Copilot Instructions for Supermarket Development

## Overview
These instructions guide GitHub Copilot in handling development tasks for the Supermarket project, including dependency upgrades, feature implementation, bug fixes, documentation updates, and general development support.

## Scope of Work
You can assist with:
- **General questions and miscellaneous topics** related to the codebase, development practices, technical topics, tools, and any other general guidance
- **All JIRA stories related to the Supermarket project** including:
  - Dependency upgrades (Ruby gems, libraries, plugins, PostgreSQL versions)
  - Feature implementation and enhancements
  - Bug fixes and troubleshooting
  - UI/UX improvements
  - Documentation updates
  - Configuration changes
  - Testing and quality assurance
  - Security fixes and improvements
  - Performance optimizations
- **Configuration documentation maintenance** - automatically updating documentation when configuration attributes are modified
- **Code reviews and analysis** - helping with code quality, best practices, and architectural decisions
- **Development environment setup** - assisting with local development, testing, and deployment

**Important:** When a JIRA ID is provided, you can help with ANY task related to the Supermarket project. For JIRA stories about other projects, politely decline and inform the user that you can only handle tasks related to the Supermarket project, but you're happy to help with general questions and miscellaneous topics.

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
   - If the story is NOT about Supermarket, respond: "I can only assist with JIRA stories about the Supermarket project. This JIRA appears to be about a different project. However, I'm happy to help with general questions, miscellaneous topics, or guidance about the Supermarket codebase."
   - If the story IS about Supermarket, proceed with the task regardless of the task type (dependency upgrades, features, bug fixes, etc.)

3. **Handle Dependabot references (for dependency upgrade tasks):**
   - If the story mentions Dependabot links, ignore those links
   - Only work with the details explicitly mentioned in the JIRA description
   - If a point only mentions Dependabot without specific package details, respond: "I need more specific details about the packages to upgrade. The description only mentions Dependabot but doesn't specify which packages need upgrading."

### 2. Branch Management
Before making any changes:
- Create a new branch named with the JIRA ID
- Example: `git checkout -b JIRA-1234`

### 3. General Development Tasks
For non-dependency upgrade tasks (feature implementation, bug fixes, UI changes, etc.):

1. **Analyze the requirements:**
   - Read the JIRA story description and acceptance criteria carefully
   - Understand the scope and expected deliverables
   - Identify the files and components that need modification

2. **Plan the implementation:**
   - Break down the task into logical steps
   - Identify potential dependencies or prerequisites
   - Consider testing requirements

3. **Follow standard development practices:**
   - Write clean, maintainable code following existing patterns
   - Add appropriate tests for new functionality
   - Update documentation as needed
   - Follow Ruby/Rails best practices and conventions

4. **Testing and validation:**
   - Run relevant test suites to ensure changes don't break existing functionality
   - Test the new feature/fix manually if applicable
   - Ensure code meets quality standards

### 4. Gemfile Locations (for dependency upgrades)
The repository contains multiple Gemfiles that need to be considered:
- `/src/supermarket/Gemfile` - Main application Gemfile
- `/src/supermarket/engines/fieri/Gemfile` - Fieri engine Gemfile
- `/omnibus/Gemfile` - Omnibus build Gemfile

**Important:** When upgrading gems, check and update ALL relevant Gemfiles where the gem is present.

### 5. Gem Upgrade Process
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
If Rails is being upgraded (any version change), you MUST update the testing framework immediately after updating Rails but BEFORE running the test suite. See section 6 for detailed Rails upgrade procedures including mandatory RSpec updates.

6. **Rails Upgrade Special Considerations:**
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

### 6. Omnibus Software Version Upgrades

Omnibus software upgrades (PostgreSQL, Redis, Nginx, etc.) are now managed through the external omnibus-software repository rather than local software definitions.

#### Step-by-Step Process:

**a. Identify Target Software and Version:**
- Determine which omnibus software needs upgrading (e.g., PostgreSQL, Redis, Nginx)
- Note the current version from any existing references in the Supermarket repository
- Identify the target version from the JIRA story

**b. Verify Version Availability in Omnibus-Software Repository:**
- **MANDATORY**: Check the omnibus-software repository: https://github.com/chef/omnibus-software
- Navigate to: `config/software/`
- Look for the software definition file (e.g., `postgresql.rb`, `redis.rb`, `nginx.rb`)
- **CRITICAL**: Verify that the target version is available in the omnibus-software repository
- If the target version is not available, **STOP** and respond:
  ```
  "The target version {VERSION} for {SOFTWARE} is not available in the omnibus-software repository at https://github.com/chef/omnibus-software/tree/main/config/software. Available versions need to be added to the omnibus-software repository first before this upgrade can proceed."
  ```

**c. Version Compatibility Check (PostgreSQL Specific):**
- For PostgreSQL upgrades specifically, check for major version changes
- If the target version requires a different major version (e.g., 13.x to 14.x or 15.x), **STOP** and respond:
  ```
  "PostgreSQL major version upgrades (e.g., from 13.x to 14.x or 15.x) cannot be automated as they require manual intervention to handle compatibility issues, data migration, and configuration changes. This upgrade needs to be handled manually by a developer familiar with PostgreSQL major version upgrade procedures."
  ```

**d. Update Local References (If Any):**
- Search the Supermarket repository for any references to the current version
- Update configuration files, documentation, or scripts that reference the old version
- **Note**: Since software definitions are now external, focus on version references rather than definition files

**e. Enumerate Security Fixes (MANDATORY for Security-Relevant Software):**
- For security-relevant software (PostgreSQL, OpenSSL, Nginx, etc.):
  - Collect all CVE IDs addressed across every intermediate version between the old version and the new version (inclusive)
  - Consult official release notes for each intermediate version
  - Record only CVE identifiers (no prose) for inclusion in `PENDING_RELEASE_NOTES.md`
  - If no CVEs are listed in any intervening versions, include: `(no CVEs reported in this upgrade range)`
  - Do NOT rely on summaries or external aggregators; always consult official release note pages

**f. Update Pending Release Notes:**
- Add a top-level Security bullet: `{SOFTWARE} <old_version> → <new_version>` followed by nested bullets of the collected CVE IDs (or the explicit no‑CVEs marker) in ascending numeric order
- Ensure security-relevant software appears prominently in release notes (PostgreSQL/Rails first when present)

**g. Dependencies and Integration:**
- Check for any cookbook dependencies that might reference specific software versions
- Update integration tests or documentation that might be version-specific
- Verify that the upgrade doesn't conflict with other omnibus software versions

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

### 9. Configuration Documentation Maintenance

**Automatic Documentation Updates:**

When any configuration attributes are added, modified, or removed in `/omnibus/cookbooks/omnibus-supermarket/attributes/default.rb`, you must automatically update the corresponding documentation in `/docs-chef-io/content/supermarket/config_rb_supermarket.md`.

**Requirements:**

1. **For New Attributes:**
   - Add proper documentation entry in the appropriate section of the markdown file
   - Follow the existing format: attribute name in backticks, colon, description, default value
   - Include the correct default value from the `default.rb` file
   - Place the new attribute in the correct section (General, Nginx, PostgreSQL, SSL, etc.)

2. **For Modified Attribute Values:**
   - Update the default value in the documentation to match the new value in `default.rb`
   - Update any description text if the functionality has changed
   - Ensure the documentation accurately reflects the current behavior

3. **For Removed Attributes:**
   - Remove the corresponding documentation entry from the markdown file
   - Check for any references elsewhere in the documentation

4. **Documentation Format:**
   ```markdown
   `default['supermarket']['section']['attribute_name']`
   
   : Description of what this attribute controls. Additional context if needed. Default value: `'value'`.
   ```

5. **Section Mapping:**
   - `nginx` attributes → **Nginx** section
   - `postgresql` attributes → **PostgreSQL** section  
   - `ssl` attributes → **SSL** section
   - `redis` attributes → **Redis** section
   - `rails` attributes → **Ruby on Rails** section
   - `sidekiq` attributes → **Sidekiq** section
   - `database` attributes → **Database** section
   - `chef_oauth2` attributes → **Oauth2** section
   - Top-level attributes → **General** section

6. **When to Apply:**
   - This applies to ANY modification of configuration attributes, not just dependency upgrades
   - Must be done AUTOMATICALLY whenever `default.rb` is modified
   - Include documentation updates in the same commit as the configuration changes

**Examples:**

*New SSL attribute added:*
```ruby
# In default.rb
default['supermarket']['ssl']['new_security_feature'] = true
```

*Must add to config_rb_supermarket.md:*
```markdown
`default['supermarket']['ssl']['new_security_feature']`

: Enables the new security feature for SSL connections. Default value: `true`.
```

*Modified existing value:*
```ruby
# Changed from '250m' to '500m'
default['supermarket']['nginx']['client_max_body_size'] = '500m'
```

*Must update in config_rb_supermarket.md:*
```markdown
`default['supermarket']['nginx']['client_max_body_size']`

: The maximum accepted body size for a client request, as indicated by the `Content-Length` request header. When the maximum accepted body size is greater than this value, a `413 Request Entity Too Large` error is returned. Default value: `500m`. See the [nginx documentation](https://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size) for additional information.
```

### 10. Quality Assurance

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
       - Then run: `gh pr create --title "Title" --body "Description" --label "ai-assisted"`
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
     - **IMPORTANT**: Always add the `ai-assisted` label to PRs created through this workflow: `gh pr create --title "Title" --body "Description" --label "ai-assisted"`
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

7. **Update JIRA AI-Assisted Field (immediately after JIRA comment):**
   - **Update the custom field to indicate AI assistance**, use the Atlassian MCP Server to update the JIRA issue
   - **Field Update Requirements:**
     - Field ID: `customfield_11170` ("Does this Work Include AI Assisted Code?")
     - Value: "Yes"
     - Format: `{"customfield_11170": {"value": "Yes"}}`
   - **Implementation using MCP Atlassian server:**
     - Use `mcp_atlassian-mcp_editJiraIssue` tool
     - Extract JIRA ID from branch name or commit message
     - Update the issue with the correct field format
   - **Verification:** Confirm the field update was successful by checking the response
   - **Error handling:** If field update fails, log the error and notify user that manual field update may be needed

8. **Buildkite Build Automation (after JIRA field update):**
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

### 11. Communication Guidelines

- **Be explicit about limitations:** Clearly state what you can and cannot do
- **Provide detailed summaries:** After each action, explain what was changed and why
- **Ask before proceeding:** Never assume the user wants to continue without confirmation
- **Handle errors gracefully:** If something fails, explain the issue and suggest alternatives

### 12. Repository-Specific Notes

- **Main application:** Located in `/src/supermarket/`
- **Omnibus packaging:** Located in `/omnibus/`
- **Multiple environments:** Consider development, production, and test dependencies
- **Legacy support:** Some gems may need to maintain compatibility with older systems

### 13. Pending Release Notes Generation

Maintain a lightweight `PENDING_RELEASE_NOTES.md` during any dependency upgrade branch so changes are ready to merge into the changelog at release time.

**CRITICAL**: Follow the official GitHub wiki structure format exactly: https://github.com/chef/supermarket/wiki/Pending-Release-Notes

Core principles:
- Short, public‑facing, non-duplicative.
- **Required sections in exact order (include only if they have content):**
  1. **Bug Fixes** - Application code fixes and upstream dependency patches
  2. **Enhancements** - New capabilities and framework upgrades that add functionality
  3. **Packaging** - Build, omnibus, infrastructure, and configuration changes
  4. **Security** - Security-relevant dependency upgrades with CVE listings
- **Header format**: Include patch release description explaining the nature of changes
- No duplication across categories. If an item appears in Security it must not reappear elsewhere.
- Each security‑relevant dependency upgrade appears exactly once under Security with: one bullet for the component (including old → new version) followed by nested bullets listing individual CVE IDs or a single nested bullet stating `(no CVEs reported in this upgrade range)`.
- No version number in the filename. Optional heading must not contain a version.
- Exclude internal / purely developer process tweaks.

**Official formatting rules (must follow exactly):**
- **Main bullets**: Use `•` (bullet character, not dash or asterisk)
- **Sub-bullets**: Use `◦` (white bullet character) for CVE listings and nested items
- **Component format**: `<Component> <old_version> → <new_version>`
- **CVE format**: One `◦` per CVE ID in plain form (`CVE-YYYY-NNNN`), no extra prose
- **No CVEs format**: Single nested bullet `◦ (no CVEs reported in this upgrade range)`
- Order components by perceived impact (Rails/PostgreSQL first) — be consistent within a file.

Steps (update iteratively as branch evolves):

1. **MANDATORY: Complete Dependency Discovery** - Extract ALL dependency changes using systematic analysis:
   ```bash
   # Get comprehensive view of all gem changes across all Gemfile.lock files
   git diff main...HEAD -- '**/Gemfile.lock' | grep -E '^[+-]\s+[a-z]' | sort | uniq
   ```
   - Extract old → new version pairs for **every gem that changed**
   - Focus on security-relevant gems: web frameworks, parsers, crypto, network libraries, database adapters
   - **Don't assume or skip dependencies** - verify every change
   - Create comprehensive list before proceeding to CVE research
   - **CRITICAL**: If user has to point out missing dependencies like "didn't you find that we have updated rack and nokogiri also", the analysis was incomplete

2. **MANDATORY CVE RESEARCH** - Collect CVE IDs from authoritative upstream sources across all intermediate versions between old and new:
  - **Security-Relevant Dependencies**: Rails, Rack, Nokogiri, OpenSSL, database adapters, authentication gems, authorization gems, session management, HTTP client gems, parsing libraries
  - **RubyGems**: Check GitHub releases and CHANGELOG.md for ALL versions in the upgrade range. Look specifically for "Security" sections and CVE references.
  - **PostgreSQL**: Explicitly open release notes for every patch version between the old and new (e.g. upgrading 13.18 → 13.22 requires scanning 13.19, 13.20, 13.21, 13.22) and aggregate all CVE IDs (e.g. CVE-2025-1094, CVE-2025-4207). Do NOT rely solely on the destination version's notes.
  - **All libraries**: Consult CHANGELOG.md, SECURITY.md, or GitHub advisories; include only CVEs actually fixed in the traversed version span.
  - **RESEARCH VERIFICATION**: For each security-relevant dependency, use `fetch_webpage` tool to check official release notes or changelogs for ALL intermediate versions to ensure no CVEs are missed.

3. **DOUBLE-CHECK CVE RESEARCH**: Before finalizing release notes, verify CVE findings by:
   - Using `fetch_webpage` to check official changelogs/release notes for each upgraded dependency
   - Ensuring all intermediate versions between old→new are checked, not just the final version
   - Cross-referencing security sections in multiple sources (releases, changelogs, security advisories)
  - **RubyGems**: Check GitHub releases and CHANGELOG.md for ALL versions in the upgrade range. Look specifically for "Security" sections and CVE references.
  - **PostgreSQL**: Explicitly open release notes for every patch version between the old and new (e.g. upgrading 13.18 → 13.22 requires scanning 13.19, 13.20, 13.21, 13.22) and aggregate all CVE IDs (e.g. CVE-2025-1094, CVE-2025-4207). Do NOT rely solely on the destination version's notes.
  - **All libraries**: Consult CHANGELOG.md, SECURITY.md, or GitHub advisories; include only CVEs actually fixed in the traversed version span.
  - **RESEARCH VERIFICATION**: For each security-relevant dependency, use `fetch_webpage` tool to check official release notes or changelogs for ALL intermediate versions to ensure no CVEs are missed.
3. **DOUBLE-CHECK CVE RESEARCH**: Before finalizing release notes, verify CVE findings by:
   - Using `fetch_webpage` to check official changelogs/release notes for each upgraded dependency
   - Ensuring all intermediate versions between old→new are checked, not just the final version
   - Cross-referencing security sections in multiple sources (releases, changelogs, security advisories)
4. Build the Security section using the new bullet + nested bullet format.
5. Classify any non-security user-visible changes as Bug Fixes or Enhancements (do NOT restate pure version bumps already covered in Security).
6. Add build/infra only changes (omnibus definitions, CI pipeline tweaks) under Packaging.
7. Validate no duplication (e.g., do not list the same version bump under Enhancements if already in Security).
8. Get user review before staging/committing.
9. At release time: move content into `CHANGELOG.md` (add version + date heading there), then delete the pending file.

"CVE Placeholder" Policy:
- **NEVER use placeholders for initial release notes generation**. Always perform comprehensive CVE research using `fetch_webpage` tool on official sources before creating any release notes.
- **MANDATORY CVE RESEARCH**: For every security-relevant dependency upgrade, use `fetch_webpage` to check:
  - Official GitHub releases pages (e.g., https://github.com/[owner]/[repo]/releases)
  - Official changelogs (e.g., https://github.com/[owner]/[repo]/blob/main/CHANGELOG.md)
  - Security-specific pages where available (e.g., https://rubyonrails.org/security)
  - ALL intermediate versions between old and new versions, not just the destination version
- **Comprehensive Analysis Required**: Use the systematic dependency discovery process (Steps 1-3 above) to ensure no security-relevant upgrades are missed
- Only if upstream retrieval fails twice AND user explicitly approves, add a nested bullet `- (CVE lookup deferred – user approved)` underneath the component; create a follow-up task to replace before merge.
- Always include an explicit `(no CVEs reported in this upgrade range)` marker for upgraded security-relevant components with none found ONLY after thorough verification.
- **Common mistake to avoid**: Do NOT assume no CVEs exist without proper research. Many security fixes are documented in release notes and changelogs that require explicit checking.
- **Quality control**: If user points out missing dependencies (e.g., "didn't you find that we have updated rack and nokogiri also"), the initial analysis was incomplete and must be redone systematically.

Updated minimal examples following official wiki format:
```
# Pending Release Notes

Patch release: dependency and security updates (PostgreSQL, Rails) plus internal dependency alignment; no functional application feature changes.

## Bug Fixes

• None in application code; fixes come via upstream dependency patches (see Security).

## Enhancements

• Rails upgraded to 7.1.5.2 enabling newer framework capabilities.

## Packaging

• Update omnibus postgresql definition 13.18 → 13.22
• Major OpenSSL upgrade from 1.0.2zi → 3.2.4 with FIPS plugin 3.1.2

## Security

• PostgreSQL 13.18 → 13.22
  ◦ CVE-2025-1094
  ◦ CVE-2025-4207
• Rails 7.0.8.7 → 7.1.5.2
  ◦ CVE-2025-1111
  ◦ CVE-2025-2222
• OpenResty 1.21 → 1.27.1.2 (includes nginx 1.21.4 → 1.27.1)
  ◦ (no CVEs reported in this upgrade range)
```

Validation checklist before committing:
- [ ] **Comprehensive dependency discovery completed**: All Gemfile.lock changes analyzed using systematic git diff approach
- [ ] **CVE research completed using `fetch_webpage` for all security-relevant dependencies**
- [ ] **All intermediate versions between old→new checked for each dependency**
- [ ] **Official release notes and changelogs reviewed for each upgraded component**
- [ ] **No missed dependencies**: Complete analysis prevents user corrections about overlooked upgrades like Rack, Nokogiri, etc.
- [ ] No version numbers in filename / heading
- [ ] **Official wiki structure followed**: Bug Fixes, Enhancements, Packaging, Security sections in exact order
- [ ] **Proper bullet formatting**: `•` for main bullets, `◦` for sub-bullets (CVE listings)
- [ ] **Patch release description included** at top explaining nature of changes
- [ ] Each upgraded security-relevant dependency listed once (no duplication elsewhere)
- [ ] Every component has CVE bullets or explicit no‑CVEs marker (ONLY after verification)
- [ ] No prose mixed with CVE IDs (IDs only)
- [ ] No unauthorized placeholders
- [ ] Non-security items classified correctly (Bug Fixes / Enhancements / Packaging) without duplication
- [ ] PostgreSQL patch range scanned (each intermediate release notes reviewed for CVEs)
- [ ] **Cross-verification completed**: Multiple sources consulted where available for security information

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
  - [ ] Create PR automatically: `gh pr create --title "Title" --body "Description" --label "ai-assisted"`
  - [ ] Or provide GitHub web URL for manual PR creation if CLI setup is not preferred
- [ ] JIRA issue updated with progress

Remember: Safety and thoroughness are more important than speed. Always err on the side of caution when making dependency changes.
