# lib/tasks/encrypt_existings.rake
namespace :data_migration do
  desc "Encrypt existing Goal values"
  task encrypt_goals: :environment do
    Goal.find_each do |goal|
      next if goal.nav_encrypted.present?

      goal.update!(
        nav_encrypted: goal.nav,
        profit_encrypted: goal.profit,
        not_net_deposited_encrypted: goal.not_net_deposited,
        deposited_encrypted: goal.deposited,
        withdrawn_encrypted: goal.withdrawn
      )
    end
    puts "Done!"
  end
end
