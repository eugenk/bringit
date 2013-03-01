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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130220182217) do

  create_table "commit_links", :force => true do |t|
    t.integer "parent_id", :null => false
    t.integer "child_id",  :null => false
  end

  add_index "commit_links", ["child_id"], :name => "index_commit_links_on_child_id"
  add_index "commit_links", ["parent_id", "child_id"], :name => "index_commit_links_on_parent_id_and_child_id", :unique => true
  add_index "commit_links", ["parent_id"], :name => "index_commit_links_on_parent_id"

  create_table "commits", :force => true do |t|
    t.string   "commit_hash",     :null => false
    t.text     "message",         :null => false
    t.string   "committer_email"
    t.string   "committer_name"
    t.datetime "committer_time"
    t.string   "author_email"
    t.string   "author_name"
    t.datetime "author_time"
    t.integer  "push_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "commits", ["commit_hash"], :name => "index_commits_on_commit_hash"
  add_index "commits", ["push_id"], :name => "index_commits_on_push_id"

  create_table "pushes", :force => true do |t|
    t.integer  "author_id"
    t.string   "push_type",     :null => false
    t.integer  "repository_id", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "pushes", ["author_id"], :name => "index_pushes_on_author_id"
  add_index "pushes", ["repository_id"], :name => "index_pushes_on_repository_id"

  create_table "repositories", :force => true do |t|
    t.string   "path",        :null => false
    t.string   "title",       :null => false
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "repositories", ["path"], :name => "index_repositories_on_path", :unique => true

  create_table "repository_owners", :force => true do |t|
    t.integer "repository_id"
    t.integer "owner_id",      :null => false
  end

  add_index "repository_owners", ["owner_id"], :name => "index_repository_owners_on_owner_id"
  add_index "repository_owners", ["repository_id", "owner_id"], :name => "index_repository_owners_on_repository_id_and_owner_id", :unique => true
  add_index "repository_owners", ["repository_id"], :name => "index_repository_owners_on_repository_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  add_foreign_key "commit_links", "commits", :name => "commit_links_child_id_fk", :column => "child_id", :dependent => :delete
  add_foreign_key "commit_links", "commits", :name => "commit_links_parent_id_fk", :column => "parent_id", :dependent => :delete

  add_foreign_key "commits", "pushes", :name => "commits_push_id_fk", :dependent => :delete

  add_foreign_key "pushes", "repositories", :name => "pushes_repository_id_fk", :dependent => :delete
  add_foreign_key "pushes", "users", :name => "pushes_author_id_fk", :column => "author_id"

  add_foreign_key "repository_owners", "repositories", :name => "repository_owners_repository_id_fk", :dependent => :delete
  add_foreign_key "repository_owners", "users", :name => "repository_owners_owner_id_fk", :column => "owner_id", :dependent => :delete

end
