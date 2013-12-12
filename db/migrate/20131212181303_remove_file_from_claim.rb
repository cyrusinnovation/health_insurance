class RemoveFileFromClaim < ActiveRecord::Migration
  def change
    remove_column :claims, :file
  end
end
