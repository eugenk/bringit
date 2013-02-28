class CreateRepositoryOwners < ActiveRecord::Migration
  def change
    create_table :repository_owners do |t|
      t.references :repository, null: false
      t.references :owner, null: false
    end
  end
end
