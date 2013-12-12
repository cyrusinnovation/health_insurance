class ChangePasswordToBlob < ActiveRecord::Migration
  def change
    remove_column :myrscs, :password
    add_column :myrscs, :password, :binary

    remove_column :oxfords, :password
    add_column :oxfords, :password, :binary
  end
end
