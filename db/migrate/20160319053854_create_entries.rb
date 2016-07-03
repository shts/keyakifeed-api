class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :title
      t.string :url
      t.integer :member_id
      t.datetime :published
      t.string :image_url_list

      t.timestamps null: false
    end
  end
end
