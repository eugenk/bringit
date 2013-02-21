class CreatePushes < ActiveRecord::Migration
  def change
    create_table :pushes do |t|
      t.references :author
      t.string :push_type, null: false
      t.references :repository, null: false
      
      t.timestamps
    end
  end
end
