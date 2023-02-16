class RemoveStatusFromSlashOrders < ActiveRecord::Migration[7.0]
  def change
    remove_column :slash_orders, :order_status, :string
  end
end
