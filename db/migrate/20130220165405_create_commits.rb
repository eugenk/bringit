class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.string :commit_hash, null: false
      t.text :message, null: false
      t.string :committer_email
      t.string :committer_name
      t.datetime :committer_time
      t.string :author_email
      t.string :author_name
      t.datetime :author_time
      t.references :push

      t.timestamps
    end

  end
end
