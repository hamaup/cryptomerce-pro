class AddAddressToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :postal_code, :integer
    add_column :customers, :prefecture, :string
    add_column :customers, :address1, :string
    add_column :customers, :address2, :text
  end
end
