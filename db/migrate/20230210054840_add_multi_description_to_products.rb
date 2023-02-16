class AddMultiDescriptionToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :multi_description, :json
  end
end
