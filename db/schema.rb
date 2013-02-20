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

  create_table "git_commit_links", :force => true do |t|
    t.integer "parent_id", :null => false
    t.integer "child_id",  :null => false
  end

  add_index "git_commit_links", ["child_id"], :name => "index_git_commit_links_on_child_id"
  add_index "git_commit_links", ["parent_id", "child_id"], :name => "index_git_commit_links_on_parent_id_and_child_id", :unique => true
  add_index "git_commit_links", ["parent_id"], :name => "index_git_commit_links_on_parent_id"

  create_table "git_commits", :force => true do |t|
    t.string   "commit_hash",     :null => false
    t.text     "message",         :null => false
    t.string   "committer_email"
    t.string   "committer_name"
    t.datetime "committer_time"
    t.string   "author_email"
    t.string   "author_name"
    t.datetime "author_time"
    t.integer  "git_push_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "git_commits", ["commit_hash"], :name => "index_git_commits_on_commit_hash"
  add_index "git_commits", ["git_push_id"], :name => "index_git_commits_on_git_push_id"

  create_table "git_pushes", :force => true do |t|
    t.integer  "author_id"
    t.string   "push_type",         :null => false
    t.integer  "git_repository_id", :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "git_pushes", ["author_id"], :name => "index_git_pushes_on_author_id"
  add_index "git_pushes", ["git_repository_id"], :name => "index_git_pushes_on_git_repository_id"

  create_table "git_repositories", :force => true do |t|
    t.string   "path",        :null => false
    t.string   "title",       :null => false
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "git_repositories", ["path"], :name => "index_git_repositories_on_path", :unique => true

  create_table "git_repository_owners", :force => true do |t|
    t.integer "git_repository_id"
    t.integer "owner_id",          :null => false
  end

  add_index "git_repository_owners", ["git_repository_id", "owner_id"], :name => "index_git_repository_owners_on_git_repository_id_and_owner_id", :unique => true
  add_index "git_repository_owners", ["git_repository_id"], :name => "index_git_repository_owners_on_git_repository_id"
  add_index "git_repository_owners", ["owner_id"], :name => "index_git_repository_owners_on_owner_id"

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

  add_foreign_key "git_commit_links", "git_commits", :name => "git_commit_links_child_id_fk", :column => "child_id", :dependent => :delete
  add_foreign_key "git_commit_links", "git_commits", :name => "git_commit_links_parent_id_fk", :column => "parent_id", :dependent => :delete

  add_foreign_key "git_commits", "git_pushes", :name => "git_commits_git_push_id_fk", :dependent => :delete

  add_foreign_key "git_pushes", "git_repositories", :name => "git_pushes_git_repository_id_fk", :dependent => :delete
  add_foreign_key "git_pushes", "users", :name => "git_pushes_author_id_fk", :column => "author_id"

  add_foreign_key "git_repository_owners", "git_repositories", :name => "git_repository_owners_git_repository_id_fk", :dependent => :delete
  add_foreign_key "git_repository_owners", "users", :name => "git_repository_owners_owner_id_fk", :column => "owner_id", :dependent => :delete

end
