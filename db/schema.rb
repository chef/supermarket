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

ActiveRecord::Schema.define(version: 20140115193908) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.integer  "user_id"
    t.string   "uid"
    t.string   "username"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.datetime "oauth_expires"
    t.string   "provider"
  end

  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

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

  create_table "emails", force: true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
  end

  add_index "emails", ["user_id"], name: "index_emails_on_user_id", using: :btree

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
    t.string   "company"
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

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: true do |t|
    t.string   "name",         null: false
    t.string   "uid",          null: false
    t.string   "secret",       null: false
    t.text     "redirect_uri", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "organization_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organization_users", ["organization_id"], name: "index_organization_users_on_organization_id", using: :btree
  add_index "organization_users", ["user_id"], name: "index_organization_users_on_user_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "prefix"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "suffix"
    t.string   "phone"
    t.integer  "primary_email_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "company"
    t.integer  "roles_mask"
  end

end
