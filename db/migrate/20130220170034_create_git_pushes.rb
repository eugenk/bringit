class CreateGitPushes < ActiveRecord::Migration
  def change
    create_table :git_pushes do |t|
      t.references :author
      t.string :push_type, null: false
      t.references :git_repository, null: false
      
      t.timestamps
    end
  end
end
