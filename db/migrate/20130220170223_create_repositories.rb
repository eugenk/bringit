class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :path, null: false
      t.string :title, null: false
      t.text :description

      t.timestamps
    end
    
  end
end
