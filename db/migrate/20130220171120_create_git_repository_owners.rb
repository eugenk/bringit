class CreateGitRepositoryOwners < ActiveRecord::Migration
  def change
    create_table :git_repository_owners do |t|
      t.references :git_repository
      t.references :owner, null: false
    end
    add_index :git_repository_owners, [:git_repository, :owner], unique: true
    add_index :git_repository_owners, :git_repository_id
    add_foreign_key :git_repository_owners, :git_repository_id, dependent: :delete
    add_index :git_repository_owners, :owner_id
    add_foreign_key :git_repository_owners, :users, column: 'owner_id', dependent: :delete
  end
end
