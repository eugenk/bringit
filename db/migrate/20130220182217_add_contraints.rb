class AddContraints < ActiveRecord::Migration
  def change
    add_index :git_repository_owners, [:git_repository_id, :owner_id], unique: true
    add_index :git_repository_owners, :git_repository_id
    add_foreign_key :git_repository_owners, :git_repositories, column: 'git_repository_id', dependent: :delete
    add_index :git_repository_owners, :owner_id
    add_foreign_key :git_repository_owners, :users, column: 'owner_id', dependent: :delete
    
    add_index :git_commits, :hash
    add_index :git_commits, :git_push_id
    add_foreign_key :git_commits, :git_pushes, column: 'git_push_id', dependent: :delete
    
    add_index :git_pushes, :author_id
    add_foreign_key :git_pushes, :users, column: 'author_id'
    add_index :git_pushes, :git_repository_id
    add_foreign_key :git_pushes, :git_repositories, column: 'git_repository_id', dependent: :delete
    
    add_index :git_repositories, :path, unique: true
    
    add_index :git_commit_links, [:parent_id, :child_id], unique: true
    add_index :git_commit_links, :parent_id
    add_foreign_key :git_commit_links, :git_commits, column: 'parent_id', dependent: :delete
    add_index :git_commit_links, :child_id
    add_foreign_key :git_commit_links, :git_commits, column: 'child_id', dependent: :delete
  end
end
