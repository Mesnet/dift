class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :api_token, null: false

      t.timestamps
    end

    # Ensure user token is uniq
    add_index :users, :api_token, unique: true
  end
end
