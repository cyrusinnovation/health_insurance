class AddSaltToTables < ActiveRecord::Migration
  def change
    add_column :myrscs, :salt, :string
    add_column :oxfords, :salt, :string
  end
end
