class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :teas, foreign_key: true
      t.references :customers, foreign_key: true
      t.string :title
      t.integer :price
      t.integer :status
      t.integer :frequency
      t.timestamps
    end
  end
end
