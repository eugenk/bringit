class CreateGitRepositories < ActiveRecord::Migration
  def change
    create_table :git_repositories do |t|
      t.string :path, null: false
      t.string :title, null: false
      t.text :description

      t.timestamps
    end
    
  end
end
