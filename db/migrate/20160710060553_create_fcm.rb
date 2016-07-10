class CreateFcm < ActiveRecord::Migration
  def change
    create_table :fcms do |t|
      t.string :reg_id

      t.timestamps null: false
    end
  end
end
