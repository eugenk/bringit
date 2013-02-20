class CreateGitCommitLinks < ActiveRecord::Migration
  def change
    create_table :git_commit_links do |t|
      t.references :parent, null: false
      t.references :child, null: false
    end
  end
end
