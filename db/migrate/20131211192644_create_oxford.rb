class CreateOxford < ActiveRecord::Migration
  def change
    create_table :oxfords do |t|
      t.string :username
      t.string :password
      t.string :claimant
      t.string :relationship
      t.references :user
    end
  end
end
