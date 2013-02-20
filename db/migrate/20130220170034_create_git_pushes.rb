class CreateGitPushes < ActiveRecord::Migration
  def change
    create_table :git_pushes do |t|
      t.references :author
      t.string :push_type, null: false
      t.references :git_repository, null: false
      
      t.timestamps
    end
    add_index :git_pushes, :author_id
    add_foreign_key :git_pushes, :users, column: 'author_id'
    add_index :git_pushes, :git_repository_id
    add_foreign_key :git_pushes, :git_repository_id, dependent: :delete
  end
end
