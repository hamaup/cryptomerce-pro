class ChangeQuantitydefaultCartItems < ActiveRecord::Migration[7.0]
  def change
    change_column_default :cart_items, :quantity, from: "", to: 1
  end
end
