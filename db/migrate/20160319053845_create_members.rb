class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :name_main
      t.string :name_sub
      t.string :image_url
      t.string :birthday
      t.string :birthplace
      t.string :blood_type
      t.string :constellation
      t.string :height

      t.timestamps null: false
    end
  end
end
