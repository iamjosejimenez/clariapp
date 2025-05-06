class FinalizeEncryptionForGoalSnapshots < ActiveRecord::Migration[8.0]
  def change
    # Eliminar los campos originales sin encriptar
    remove_column :goal_snapshots, :nav, :float
    remove_column :goal_snapshots, :profit, :float
    remove_column :goal_snapshots, :not_net_deposited, :float
    remove_column :goal_snapshots, :deposited, :float
    remove_column :goal_snapshots, :withdrawn, :float

    # Renombrar los campos encriptados
    rename_column :goal_snapshots, :nav_encrypted, :nav
    rename_column :goal_snapshots, :profit_encrypted, :profit
    rename_column :goal_snapshots, :not_net_deposited_encrypted, :not_net_deposited
    rename_column :goal_snapshots, :deposited_encrypted, :deposited
    rename_column :goal_snapshots, :withdrawn_encrypted, :withdrawn
  end
end
