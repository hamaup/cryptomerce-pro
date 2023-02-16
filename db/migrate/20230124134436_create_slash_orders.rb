class CreateSlashOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :slash_orders do |t|
      t.string :order_code, limit: 256, null: false, unique: true
      t.decimal :amount, precision: 31, scale: 18
      t.string :fiat_symbol, limit: 3
      t.string :payment_token, limit: 32, null: false, unique: true
      t.string :order_status, null: false
      t.string :transaction_hash
      t.timestamps
    end
  end
end
