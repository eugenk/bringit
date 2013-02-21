class AddContraints < ActiveRecord::Migration
  def change
    add_index :repository_owners, [:repository_id, :owner_id], unique: true
    add_index :repository_owners, :repository_id
    add_foreign_key :repository_owners, :repositories, column: 'repository_id', dependent: :delete
    add_index :repository_owners, :owner_id
    add_foreign_key :repository_owners, :users, column: 'owner_id', dependent: :delete
    
    add_index :commits, :commit_hash
    add_index :commits, :push_id
    add_foreign_key :commits, :pushes, column: 'push_id', dependent: :delete
    
    add_index :pushes, :author_id
    add_foreign_key :pushes, :users, column: 'author_id'
    add_index :pushes, :repository_id
    add_foreign_key :pushes, :repositories, column: 'repository_id', dependent: :delete
    
    add_index :repositories, :path, unique: true
    
    add_index :commit_links, [:parent_id, :child_id], unique: true
    add_index :commit_links, :parent_id
    add_foreign_key :commit_links, :commits, column: 'parent_id', dependent: :delete
    add_index :commit_links, :child_id
    add_foreign_key :commit_links, :commits, column: 'child_id', dependent: :delete
  end
end
