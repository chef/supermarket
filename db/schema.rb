# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140709140311) do

  create_table "accounts", force: true do |t|
    t.integer  "user_id"
    t.string   "uid"
    t.string   "username"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.datetime "oauth_expires"
    t.string   "provider"
    t.string   "oauth_refresh_token"
  end

  add_index "accounts", ["oauth_expires"], name: "index_accounts_on_oauth_expires", using: :btree
  add_index "accounts", ["uid", "provider"], name: "index_accounts_on_uid_and_provider", unique: true, using: :btree
  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree
  add_index "accounts", ["username", "provider"], name: "index_accounts_on_username_and_provider", unique: true, using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "categories", ["slug"], name: "index_categories_on_slug", using: :btree

  create_table "ccla_signatures", force: true do |t|
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
  end

  add_index "ccla_signatures", ["ccla_id"], name: "index_ccla_signatures_on_ccla_id", using: :btree
  add_index "ccla_signatures", ["organization_id"], name: "index_ccla_signatures_on_organization_id", using: :btree
  add_index "ccla_signatures", ["user_id"], name: "index_ccla_signatures_on_user_id", using: :btree

  create_table "cclas", force: true do |t|
    t.string   "version"
    t.text     "head"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contributors", force: true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contributors", ["organization_id"], name: "index_contributors_on_organization_id", using: :btree
  add_index "contributors", ["user_id", "organization_id"], name: "index_contributors_on_user_id_and_organization_id", unique: true, using: :btree
  add_index "contributors", ["user_id"], name: "index_contributors_on_user_id", using: :btree

  create_table "cookbook_collaborators", force: true do |t|
    t.integer  "cookbook_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cookbook_collaborators", ["user_id", "cookbook_id"], name: "index_cookbook_collaborators_on_user_id_and_cookbook_id", unique: true, using: :btree

  create_table "cookbook_dependencies", force: true do |t|
    t.string   "name",                                     null: false
    t.string   "version_constraint",  default: ">= 0.0.0", null: false
    t.integer  "cookbook_version_id",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cookbook_id"
  end

  add_index "cookbook_dependencies", ["cookbook_id"], name: "index_cookbook_dependencies_on_cookbook_id", using: :btree
  add_index "cookbook_dependencies", ["cookbook_version_id", "name", "version_constraint"], name: "cookbook_dependencies_unique_by_name_and_constraint", unique: true, using: :btree
  add_index "cookbook_dependencies", ["cookbook_version_id"], name: "index_cookbook_dependencies_on_cookbook_version_id", using: :btree

  create_table "cookbook_followers", force: true do |t|
    t.integer  "cookbook_id", null: false
    t.integer  "user_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cookbook_followers", ["cookbook_id", "user_id"], name: "index_cookbook_followers_on_cookbook_id_and_user_id", unique: true, using: :btree

  create_table "cookbook_version_platforms", force: true do |t|
    t.integer  "cookbook_version_id"
    t.integer  "supported_platform_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cookbook_version_platforms", ["cookbook_version_id", "supported_platform_id"], name: "index_cvp_on_cvi_and_spi", unique: true, using: :btree

  create_table "cookbook_versions", force: true do |t|
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
  end

  add_index "cookbook_versions", ["legacy_id"], name: "index_cookbook_versions_on_legacy_id", unique: true, using: :btree
  add_index "cookbook_versions", ["version", "cookbook_id"], name: "index_cookbook_versions_on_version_and_cookbook_id", unique: true, using: :btree
  add_index "cookbook_versions", ["version"], name: "index_cookbook_versions_on_version", using: :btree

  create_table "cookbooks", force: true do |t|
    t.string   "name",                                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_url"
    t.boolean  "deprecated",               default: false
    t.integer  "category_id",                              null: false
    t.string   "lowercase_name"
    t.string   "issues_url"
    t.integer  "cookbook_followers_count", default: 0
    t.integer  "user_id"
    t.integer  "replacement_id"
    t.integer  "web_download_count",       default: 0
    t.integer  "api_download_count",       default: 0
  end

  add_index "cookbooks", ["lowercase_name"], name: "index_cookbooks_on_lowercase_name", unique: true, using: :btree
  add_index "cookbooks", ["name"], name: "index_cookbooks_on_name", using: :btree
  add_index "cookbooks", ["user_id"], name: "index_cookbooks_on_user_id", using: :btree

  create_table "curry_commit_authors", force: true do |t|
    t.string   "login"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "authorized_to_contribute", default: false, null: false
  end

  add_index "curry_commit_authors", ["email"], name: "index_curry_commit_authors_on_email", unique: true, using: :btree
  add_index "curry_commit_authors", ["login"], name: "index_curry_commit_authors_on_login", unique: true, using: :btree

  create_table "curry_pull_request_commit_authors", force: true do |t|
    t.integer "pull_request_id",  null: false
    t.integer "commit_author_id", null: false
  end

  add_index "curry_pull_request_commit_authors", ["commit_author_id", "pull_request_id"], name: "curry_pr_commit_author_ids", unique: true, using: :btree

  create_table "curry_pull_request_updates", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action"
    t.integer  "pull_request_id", null: false
  end

  create_table "curry_pull_requests", force: true do |t|
    t.string   "number",        null: false
    t.integer  "repository_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "curry_pull_requests", ["number", "repository_id"], name: "index_curry_pull_requests_on_number_and_repository_id", unique: true, using: :btree

  create_table "curry_repositories", force: true do |t|
    t.string   "owner"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "callback_url"
  end

  create_table "hits", force: true do |t|
    t.string  "label",             null: false
    t.integer "total", default: 0, null: false
  end

  add_index "hits", ["label"], name: "index_hits_on_label", unique: true, using: :btree

  create_table "icla_signatures", force: true do |t|
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
  end

  add_index "icla_signatures", ["icla_id"], name: "index_icla_signatures_on_icla_id", using: :btree
  add_index "icla_signatures", ["user_id"], name: "index_icla_signatures_on_user_id", using: :btree

  create_table "iclas", force: true do |t|
    t.string   "version"
    t.text     "head"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", force: true do |t|
    t.integer  "organization_id"
    t.string   "email"
    t.string   "token"
    t.boolean  "admin"
    t.boolean  "accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["organization_id"], name: "index_invitations_on_organization_id", using: :btree

  create_table "organizations", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supported_platforms", force: true do |t|
    t.string   "name",                                    null: false
    t.string   "version_constraint", default: ">= 0.0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "supported_platforms", ["name", "version_constraint"], name: "index_supported_platforms_on_name_and_version_constraint", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "company"
    t.integer  "roles_mask"
    t.string   "email",               default: "",   null: false
    t.string   "jira_username"
    t.string   "irc_nickname"
    t.string   "twitter_username"
    t.text     "public_key"
    t.boolean  "email_notifications", default: true
  end

end
