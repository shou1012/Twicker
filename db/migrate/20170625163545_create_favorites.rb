class CreateFavorites < ActiveRecord::Migration[5.0]
  def change
    create_table :favorites do |t|
      t.integer :user_id
      t.string :timeline_source
      t.string :timeline_id
      t.string :string
      t.string :timestamp

      t.timestamps
    end
  end
end
