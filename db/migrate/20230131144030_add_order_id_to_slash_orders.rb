class AddOrderIdToSlashOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :slash_orders, :order, foreign_key: true, null: false
  end
end
