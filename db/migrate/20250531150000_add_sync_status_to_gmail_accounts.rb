class AddSyncStatusToGmailAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :gmail_accounts, :sync_status, :string, default: "idle", null: false
    add_column :gmail_accounts, :last_synced_at, :datetime
  end
end
