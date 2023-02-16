class AddSymbolAndTransactionCodeToSlashOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :slash_orders, :symbol, :string
    add_column :slash_orders, :transaction_code, :text
    add_column :slash_orders, :chain_id, :integer
    add_column :slash_orders, :verify_token, :text
    add_column :slash_orders, :result, :boolean
  end
end
