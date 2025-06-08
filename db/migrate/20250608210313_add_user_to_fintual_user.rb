class AddUserToFintualUser < ActiveRecord::Migration[8.0]
  def change
    add_reference :fintual_users, :user, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        say_with_time "Backfilling user_id in fintual_users based on email" do
          execute <<-SQL.squish
            UPDATE fintual_users
            SET user_id = users.id
            FROM users
            WHERE users.email_address = fintual_users.email
          SQL
        end
      end
    end

    change_column_null :fintual_users, :user_id, false
  end
end
