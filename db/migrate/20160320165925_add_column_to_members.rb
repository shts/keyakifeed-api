class AddColumnToMembers < ActiveRecord::Migration
  def change
    add_column :members, :favorite, :integer
  end
end
