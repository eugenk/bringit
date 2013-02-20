class CreateGitCommitLinks < ActiveRecord::Migration
  def change
    create_table :git_commit_links do |t|
      t.references :parent, null: false
      t.references :child, null: false
    end
    add_index :git_commit_links, [:parent, :child], unique: true
    add_index :git_commit_links, :parent_id
    add_foreign_key :git_commit_links, :git_commits, column: 'parent_id', dependent: :delete
    add_index :git_commit_links, :child_id
    add_foreign_key :git_commit_links, :git_commits, column: 'child_id', dependent: :delete
  end
end
