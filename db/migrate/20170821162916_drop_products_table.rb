class DropProductsTable < ActiveRecord::Migration[5.1]
  def change
     drop_table :log
  end
end
