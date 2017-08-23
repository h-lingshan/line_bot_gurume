class CreateTalkData < ActiveRecord::Migration[5.1]
  def change
    create_table :talk_data do |t|
      t.string :user_id
      t.string :type
      t.string :content
      t.string :current_qid
      t.string :parent_qid
      t.timestamps
    end
  end
end
