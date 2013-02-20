class CreateGitRepositoryOwners < ActiveRecord::Migration
  def change
    create_table :git_repository_owners do |t|
      t.references :git_repository
      t.references :owner, null: false
    end
  end
end
