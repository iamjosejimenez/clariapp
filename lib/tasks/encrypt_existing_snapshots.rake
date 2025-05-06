# lib/tasks/encrypt_existing_snapshots.rake
namespace :data_migration do
  desc "Encrypt existing GoalSnapshot values"
  task encrypt_goal_snapshots: :environment do
    GoalSnapshot.find_each do |snapshot|
      next if snapshot.nav_encrypted.present?

      snapshot.update!(
        nav_encrypted: snapshot.nav,
        profit_encrypted: snapshot.profit,
        not_net_deposited_encrypted: snapshot.not_net_deposited,
        deposited_encrypted: snapshot.deposited,
        withdrawn_encrypted: snapshot.withdrawn
      )
    end
    puts "Done!"
  end
end
