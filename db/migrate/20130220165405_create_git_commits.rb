class CreateGitCommits < ActiveRecord::Migration
  def change
    create_table :git_commits do |t|
      t.string :hash, null: false
      t.text :message, null: false
      t.string :committer_email
      t.string :committer_name
      t.datetime :committer_time
      t.string :author_email
      t.string :author_name
      t.datetime :author_time
      t.references :git_push

      t.timestamps
    end

    add_index :git_commits, :hash
    add_index :git_commits, :git_push_id
    add_foreign_key :git_commits, :git_push_id, dependent: :delete
  end
end
