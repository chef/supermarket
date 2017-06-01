# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170203223651) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "accounts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "uid"
    t.string   "username"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.datetime "oauth_expires"
    t.string   "provider"
    t.string   "oauth_refresh_token"
    t.index ["oauth_expires"], name: "index_accounts_on_oauth_expires", using: :btree
    t.index ["uid", "provider"], name: "index_accounts_on_uid_and_provider", unique: true, using: :btree
    t.index ["uid"], name: "index_accounts_on_uid", using: :btree
    t.index ["user_id"], name: "index_accounts_on_user_id", using: :btree
    t.index ["username", "provider"], name: "index_accounts_on_username_and_provider", unique: true, using: :btree
    t.index ["username"], name: "index_accounts_on_username", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.index ["slug"], name: "index_categories_on_slug", using: :btree
  end

  create_table "ccla_signatures", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.integer  "ccla_id"
    t.datetime "signed_at"
    t.string   "prefix"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "suffix"
    t.string   "email"
    t.string   "phone"
    t.string   "company"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ccla_id"], name: "index_ccla_signatures_on_ccla_id", using: :btree
    t.index ["organization_id"], name: "index_ccla_signatures_on_organization_id", using: :btree
    t.index ["user_id"], name: "index_ccla_signatures_on_user_id", using: :btree
  end

  create_table "cclas", force: :cascade do |t|
    t.string   "version"
    t.text     "head"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["version"], name: "index_cclas_on_version", using: :btree
  end

  create_table "cla_reports", force: :cascade do |t|
    t.integer  "first_ccla_id"
    t.integer  "last_ccla_id"
    t.integer  "first_icla_id"
    t.integer  "last_icla_id"
    t.string   "csv_file_name"
    t.string   "csv_content_type"
    t.integer  "csv_file_size"
    t.datetime "csv_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collaborators", force: :cascade do |t|
    t.integer  "resourceable_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "resourceable_type"
    t.integer  "group_id"
    t.index ["user_id", "resourceable_type", "resourceable_id", "group_id"], name: "index_collaborators_on_user_id_and_group_id_and_resourceable", unique: true, using: :btree
  end

  create_table "contributor_request_responses", force: :cascade do |t|
    t.integer  "contributor_request_id", null: false
    t.string   "decision",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contributor_request_id"], name: "index_contributor_request_responses_on_contributor_request_id", unique: true, using: :btree
  end

  create_table "contributor_requests", force: :cascade do |t|
    t.integer  "organization_id",   null: false
    t.integer  "user_id",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ccla_signature_id", null: false
    t.index ["organization_id", "user_id"], name: "index_contributor_requests_on_organization_id_and_user_id", unique: true, using: :btree
  end

  create_table "contributors", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["organization_id"], name: "index_contributors_on_organization_id", using: :btree
    t.index ["user_id", "organization_id"], name: "index_contributors_on_user_id_and_organization_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_contributors_on_user_id", using: :btree
  end

  create_table "cookbook_dependencies", force: :cascade do |t|
    t.string   "name",                                     null: false
    t.string   "version_constraint",  default: ">= 0.0.0", null: false
    t.integer  "cookbook_version_id",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cookbook_id"
    t.index ["cookbook_id"], name: "index_cookbook_dependencies_on_cookbook_id", using: :btree
    t.index ["cookbook_version_id", "name", "version_constraint"], name: "cookbook_dependencies_unique_by_name_and_constraint", unique: true, using: :btree
    t.index ["cookbook_version_id"], name: "index_cookbook_dependencies_on_cookbook_version_id", using: :btree
  end

  create_table "cookbook_followers", force: :cascade do |t|
    t.integer  "cookbook_id", null: false
    t.integer  "user_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cookbook_id", "user_id"], name: "index_cookbook_followers_on_cookbook_id_and_user_id", unique: true, using: :btree
  end

  create_table "cookbook_version_platforms", force: :cascade do |t|
    t.integer  "cookbook_version_id"
    t.integer  "supported_platform_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cookbook_version_id", "supported_platform_id"], name: "index_cvp_on_cvi_and_spi", unique: true, using: :btree
  end

  create_table "cookbook_versions", force: :cascade do |t|
    t.integer  "cookbook_id"
    t.string   "license"
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tarball_file_name"
    t.string   "tarball_content_type"
    t.integer  "tarball_file_size"
    t.datetime "tarball_updated_at"
    t.text     "readme",                default: "",    null: false
    t.string   "readme_extension",      default: "",    null: false
    t.boolean  "dependencies_imported", default: false
    t.text     "description"
    t.integer  "legacy_id"
    t.integer  "web_download_count",    default: 0
    t.integer  "api_download_count",    default: 0
    t.text     "changelog"
    t.string   "changelog_extension",   default: "",    null: false
    t.json     "chef_versions"
    t.json     "ohai_versions"
    t.integer  "user_id"
    t.index ["legacy_id"], name: "index_cookbook_versions_on_legacy_id", unique: true, using: :btree
    t.index ["version", "cookbook_id"], name: "index_cookbook_versions_on_version_and_cookbook_id", unique: true, using: :btree
    t.index ["version"], name: "index_cookbook_versions_on_version", using: :btree
  end

  create_table "cookbooks", force: :cascade do |t|
    t.string   "name",                                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_url"
    t.boolean  "deprecated",               default: false
    t.integer  "category_id"
    t.string   "lowercase_name"
    t.string   "issues_url"
    t.integer  "cookbook_followers_count", default: 0
    t.integer  "user_id"
    t.integer  "replacement_id"
    t.integer  "web_download_count",       default: 0
    t.integer  "api_download_count",       default: 0
    t.boolean  "featured",                 default: false
    t.boolean  "up_for_adoption"
    t.boolean  "privacy"
    t.integer  "badges_mask",              default: 0,     null: false
    t.index ["lowercase_name"], name: "index_cookbooks_on_lowercase_name", unique: true, using: :btree
    t.index ["name"], name: "index_cookbooks_on_name", using: :btree
    t.index ["user_id"], name: "index_cookbooks_on_user_id", using: :btree
  end

  create_table "curry_commit_authors", force: :cascade do |t|
    t.string   "login"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "authorized_to_contribute", default: false, null: false
    t.index ["email"], name: "index_curry_commit_authors_on_email", unique: true, using: :btree
    t.index ["login"], name: "index_curry_commit_authors_on_login", unique: true, using: :btree
  end

  create_table "curry_pull_request_comments", force: :cascade do |t|
    t.integer  "github_id",                                null: false
    t.integer  "pull_request_id",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "unauthorized_commit_authors", default: [],              array: true
    t.index ["github_id"], name: "index_curry_pull_request_comments_on_github_id", unique: true, using: :btree
    t.index ["pull_request_id"], name: "index_curry_pull_request_comments_on_pull_request_id", using: :btree
  end

  create_table "curry_pull_request_commit_authors", force: :cascade do |t|
    t.integer "pull_request_id",  null: false
    t.integer "commit_author_id", null: false
    t.index ["commit_author_id", "pull_request_id"], name: "curry_pr_commit_author_ids", unique: true, using: :btree
    t.index ["commit_author_id"], name: "index_curry_pull_request_commit_authors_on_commit_author_id", using: :btree
    t.index ["pull_request_id"], name: "index_curry_pull_request_commit_authors_on_pull_request_id", using: :btree
  end

  create_table "curry_pull_request_updates", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action"
    t.integer  "pull_request_id", null: false
  end

  create_table "curry_pull_requests", force: :cascade do |t|
    t.string   "number",        null: false
    t.integer  "repository_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "maintainer_id"
    t.index ["maintainer_id"], name: "index_curry_pull_requests_on_maintainer_id", using: :btree
    t.index ["number", "repository_id"], name: "index_curry_pull_requests_on_number_and_repository_id", unique: true, using: :btree
    t.index ["repository_id"], name: "index_curry_pull_requests_on_repository_id", using: :btree
  end

  create_table "curry_repositories", force: :cascade do |t|
    t.string   "owner",        null: false
    t.string   "name",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "callback_url", null: false
  end

  create_table "curry_repository_maintainers", force: :cascade do |t|
    t.integer  "repository_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_preferences", force: :cascade do |t|
    t.integer  "user_id",         null: false
    t.integer  "system_email_id", null: false
    t.string   "token",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["token"], name: "index_email_preferences_on_token", unique: true, using: :btree
    t.index ["user_id", "system_email_id"], name: "index_email_preferences_on_user_id_and_system_email_id", unique: true, using: :btree
  end

  create_table "group_members", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_resources", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "resourceable_id"
    t.string   "resourceable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hits", force: :cascade do |t|
    t.string  "label",             null: false
    t.integer "total", default: 0, null: false
    t.index ["label"], name: "index_hits_on_label", unique: true, using: :btree
  end

  create_table "icla_signatures", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "signed_at"
    t.string   "prefix"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "suffix"
    t.string   "email"
    t.string   "phone"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.integer  "icla_id"
    t.index ["icla_id"], name: "index_icla_signatures_on_icla_id", using: :btree
    t.index ["user_id"], name: "index_icla_signatures_on_user_id", using: :btree
  end

  create_table "iclas", force: :cascade do |t|
    t.string   "version"
    t.text     "head"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["version"], name: "index_iclas_on_version", using: :btree
  end

  create_table "invitations", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "email"
    t.string   "token"
    t.boolean  "admin"
    t.boolean  "accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["organization_id"], name: "index_invitations_on_organization_id", using: :btree
  end

  create_table "metric_results", force: :cascade do |t|
    t.integer  "cookbook_version_id"
    t.integer  "quality_metric_id",   null: false
    t.boolean  "failure"
    t.string   "feedback"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ownership_transfer_requests", force: :cascade do |t|
    t.integer  "cookbook_id",               null: false
    t.integer  "recipient_id",              null: false
    t.integer  "sender_id",                 null: false
    t.string   "token",                     null: false
    t.boolean  "accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "add_owner_as_collaborator"
    t.index ["cookbook_id"], name: "index_ownership_transfer_requests_on_cookbook_id", using: :btree
    t.index ["recipient_id"], name: "index_ownership_transfer_requests_on_recipient_id", using: :btree
    t.index ["token"], name: "index_ownership_transfer_requests_on_token", unique: true, using: :btree
  end

  create_table "quality_metrics", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "admin_only", default: false, null: false
  end

  create_table "supported_platforms", force: :cascade do |t|
    t.string   "name",                                    null: false
    t.string   "version_constraint", default: ">= 0.0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "version_constraint"], name: "index_supported_platforms_on_name_and_version_constraint", unique: true, using: :btree
  end

  create_table "system_emails", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tools", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "type"
    t.text     "description"
    t.string   "source_url"
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lowercase_name"
    t.string   "slug"
    t.boolean  "up_for_adoption"
    t.index ["lowercase_name"], name: "index_tools_on_lowercase_name", unique: true, using: :btree
    t.index ["slug"], name: "index_tools_on_slug", unique: true, using: :btree
    t.index ["user_id"], name: "index_tools_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "company"
    t.integer  "roles_mask"
    t.string   "email",              default: "", null: false
    t.string   "jira_username"
    t.string   "irc_nickname"
    t.string   "twitter_username"
    t.text     "public_key"
    t.string   "install_preference"
  end

end
