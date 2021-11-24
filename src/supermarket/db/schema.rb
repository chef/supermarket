# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_10_21_105430) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "uid"
    t.string "username"
    t.string "oauth_token"
    t.string "oauth_secret"
    t.datetime "oauth_expires"
    t.string "provider"
    t.string "oauth_refresh_token"
    t.index ["oauth_expires"], name: "index_accounts_on_oauth_expires"
    t.index ["uid", "provider"], name: "index_accounts_on_uid_and_provider", unique: true
    t.index ["uid"], name: "index_accounts_on_uid"
    t.index ["user_id"], name: "index_accounts_on_user_id"
    t.index ["username", "provider"], name: "index_accounts_on_username_and_provider", unique: true
    t.index ["username"], name: "index_accounts_on_username"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
    t.index ["slug"], name: "index_categories_on_slug"
  end

  create_table "collaborators", id: :serial, force: :cascade do |t|
    t.integer "resourceable_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "resourceable_type"
    t.integer "group_id"
    t.index ["user_id", "resourceable_type", "resourceable_id", "group_id"], name: "index_collaborators_on_user_id_and_group_id_and_resourceable", unique: true
  end

  create_table "contributor_request_responses", id: :serial, force: :cascade do |t|
    t.integer "contributor_request_id", null: false
    t.string "decision", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contributor_request_id"], name: "index_contributor_request_responses_on_contributor_request_id", unique: true
  end

  create_table "contributor_requests", id: :serial, force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "ccla_signature_id", null: false
    t.index ["organization_id", "user_id"], name: "index_contributor_requests_on_organization_id_and_user_id", unique: true
  end

  create_table "contributors", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.boolean "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["organization_id"], name: "index_contributors_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_contributors_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_contributors_on_user_id"
  end

  create_table "cookbook_dependencies", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "version_constraint", default: ">= 0.0.0", null: false
    t.integer "cookbook_version_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cookbook_id"
    t.index ["cookbook_id"], name: "index_cookbook_dependencies_on_cookbook_id"
    t.index ["cookbook_version_id", "name", "version_constraint"], name: "cookbook_dependencies_unique_by_name_and_constraint", unique: true
    t.index ["cookbook_version_id"], name: "index_cookbook_dependencies_on_cookbook_version_id"
  end

  create_table "cookbook_followers", id: :serial, force: :cascade do |t|
    t.integer "cookbook_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cookbook_id", "user_id"], name: "index_cookbook_followers_on_cookbook_id_and_user_id", unique: true
  end

  create_table "cookbook_version_platforms", id: :serial, force: :cascade do |t|
    t.integer "cookbook_version_id"
    t.integer "supported_platform_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cookbook_version_id", "supported_platform_id"], name: "index_cvp_on_cvi_and_spi", unique: true
  end

  create_table "cookbook_versions", id: :serial, force: :cascade do |t|
    t.integer "cookbook_id"
    t.string "license"
    t.string "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "tarball_file_name"
    t.string "tarball_content_type"
    t.integer "tarball_file_size"
    t.datetime "tarball_updated_at"
    t.text "readme", default: "", null: false
    t.string "readme_extension", default: "", null: false
    t.boolean "dependencies_imported", default: false
    t.text "description"
    t.integer "legacy_id"
    t.integer "web_download_count", default: 0
    t.integer "api_download_count", default: 0
    t.text "changelog"
    t.string "changelog_extension", default: "", null: false
    t.json "chef_versions"
    t.json "ohai_versions"
    t.integer "user_id"
    t.string "spdx_license_url"
    t.index ["legacy_id"], name: "index_cookbook_versions_on_legacy_id", unique: true
    t.index ["version", "cookbook_id"], name: "index_cookbook_versions_on_version_and_cookbook_id", unique: true
    t.index ["version"], name: "index_cookbook_versions_on_version"
  end

  create_table "cookbooks", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "source_url"
    t.boolean "deprecated", default: false
    t.integer "category_id"
    t.string "lowercase_name"
    t.string "issues_url"
    t.integer "cookbook_followers_count", default: 0
    t.integer "user_id"
    t.integer "replacement_id"
    t.integer "web_download_count", default: 0
    t.integer "api_download_count", default: 0
    t.boolean "featured", default: false
    t.boolean "up_for_adoption"
    t.boolean "privacy"
    t.integer "badges_mask", default: 0, null: false
    t.string "deprecation_reason"
    t.index ["lowercase_name"], name: "index_cookbooks_on_lowercase_name", unique: true
    t.index ["name"], name: "index_cookbooks_on_name"
    t.index ["user_id"], name: "index_cookbooks_on_user_id"
  end

  create_table "email_preferences", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "system_email_id", null: false
    t.string "token", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["token"], name: "index_email_preferences_on_token", unique: true
    t.index ["user_id", "system_email_id"], name: "index_email_preferences_on_user_id_and_system_email_id", unique: true
  end

  create_table "group_members", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.boolean "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "group_id"], name: "index_group_members_on_user_id_and_group_id", unique: true
  end

  create_table "group_resources", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "resourceable_id"
    t.string "resourceable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hits", id: :serial, force: :cascade do |t|
    t.string "label", null: false
    t.integer "total", default: 0, null: false
    t.index ["label"], name: "index_hits_on_label", unique: true
  end

  create_table "invitations", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "email"
    t.string "token"
    t.boolean "admin"
    t.boolean "accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["organization_id"], name: "index_invitations_on_organization_id"
  end

  create_table "metric_results", id: :serial, force: :cascade do |t|
    t.integer "cookbook_version_id"
    t.integer "quality_metric_id", null: false
    t.boolean "failure"
    t.string "feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ownership_transfer_requests", id: :serial, force: :cascade do |t|
    t.integer "cookbook_id", null: false
    t.integer "recipient_id", null: false
    t.integer "sender_id", null: false
    t.string "token", null: false
    t.boolean "accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "add_owner_as_collaborator"
    t.index ["cookbook_id"], name: "index_ownership_transfer_requests_on_cookbook_id"
    t.index ["recipient_id"], name: "index_ownership_transfer_requests_on_recipient_id"
    t.index ["token"], name: "index_ownership_transfer_requests_on_token", unique: true
  end

  create_table "quality_metrics", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin_only", default: false, null: false
    t.index ["name"], name: "index_quality_metrics_on_name", unique: true
  end

  create_table "supported_platforms", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "version_constraint", default: ">= 0.0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "version_constraint"], name: "index_supported_platforms_on_name_and_version_constraint", unique: true
  end

  create_table "system_emails", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_system_emails_on_name", unique: true
  end

  create_table "tools", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "type"
    t.text "description"
    t.string "source_url"
    t.text "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "lowercase_name"
    t.string "slug"
    t.boolean "up_for_adoption"
    t.index ["lowercase_name"], name: "index_tools_on_lowercase_name", unique: true
    t.index ["slug"], name: "index_tools_on_slug", unique: true
    t.index ["user_id"], name: "index_tools_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "company"
    t.integer "roles_mask"
    t.string "email", default: "", null: false
    t.string "jira_username"
    t.string "twitter_username"
    t.text "public_key"
    t.string "install_preference"
    t.string "slack_username"
  end

end
