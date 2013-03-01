class CreateRepositoryOwners < ActiveRecord::Migration
  def change
    create_table :repository_owners do |t|
      t.references :repository
      t.references :owner, null: false
    end
  end
end
