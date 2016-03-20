class AddColumnStatusToMembers < ActiveRecord::Migration
  def change
    add_column :members, :key, :string
    add_column :members, :status, :string
    add_column :members, :message_url, :string
  end
end
