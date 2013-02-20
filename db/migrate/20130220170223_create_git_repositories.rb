class CreateGitRepositories < ActiveRecord::Migration
  def change
    create_table :git_repositories do |t|
      t.string :path, null: false
      t.string :title, null: false
      t.text :description

      t.timestamps
    end
    
    add_index :git_repositories, :path, unique: true
  end
end
