class DropEob < ActiveRecord::Migration
  def change
    drop_table :eobs
  end
end
