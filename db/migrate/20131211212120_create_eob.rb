class CreateEob < ActiveRecord::Migration
  def change
    create_table :eobs do |t|
      t.string :claim_number
    end
    add_index :eobs, :claim_number
  end
end
