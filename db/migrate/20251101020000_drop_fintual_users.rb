class DropFintualUsers < ActiveRecord::Migration[8.1]
  def up
    remove_foreign_key :fintual_users, :users if foreign_key_exists?(:fintual_users, :users)
    drop_table :fintual_users, if_exists: true
  end

  def down
    create_table :fintual_users do |t|
      t.string :email
      t.text :token
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :fintual_users, :email, unique: true
  end
end
