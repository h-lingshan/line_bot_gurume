class DropProductsTable2 < ActiveRecord::Migration[5.1]
  def change
    drop_table :talk_data
  end
end
