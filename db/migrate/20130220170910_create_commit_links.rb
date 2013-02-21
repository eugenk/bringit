class CreateCommitLinks < ActiveRecord::Migration
  def change
    create_table :commit_links do |t|
      t.references :parent, null: false
      t.references :child, null: false
    end
  end
end
