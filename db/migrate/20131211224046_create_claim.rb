class CreateClaim < ActiveRecord::Migration
  def change
    create_table :claims do |t|
      t.date :service_date
      t.string :service_code
      t.float :deductible_amount
      t.string :file
      t.string :claim_number
      t.string :state, default: 'unprocessed'
      t.references :oxford
      t.timestamps
    end
  end
end
