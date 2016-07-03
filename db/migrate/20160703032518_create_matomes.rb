class CreateMatomes < ActiveRecord::Migration
  def change
    create_table :matomes do |t|
      t.string :feed_title
      t.string :feed_url
      t.string :feed_last_modified
      t.string :entry_title
      t.string :entry_url
      t.datetime :entry_published
      t.string :image_url_list
      t.string :entry_categories

      t.timestamps null: false
    end
  end
end
