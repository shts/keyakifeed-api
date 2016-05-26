class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :title
      t.string :url
      t.string :thumbnail_url
      t.date :published
      t.string :image_url_list

      t.timestamps null: false
    end
  end
end
