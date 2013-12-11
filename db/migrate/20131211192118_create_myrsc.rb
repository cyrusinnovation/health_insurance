class CreateMyrsc < ActiveRecord::Migration
  def change
    create_table :myrscs do |t|
      t.string :username
      t.string :password
      t.references :user
    end
  end
end
