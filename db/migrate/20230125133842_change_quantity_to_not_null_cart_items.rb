class ChangeQuantityToNotNullCartItems < ActiveRecord::Migration[7.0]
  def change
    change_column_null :cart_items, :quantity, false
  end
end
