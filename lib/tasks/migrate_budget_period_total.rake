# lib/tasks/encrypt_existings.rake
namespace :data_migration do
  desc "Set total for existing BudgetPeriod records"
  task set_budget_periods_total: :environment do
    Budget.find_each do |budget|
      budget.budget_periods.each do |period|
        period.total = budget.amount
        period.save
      end
    end
    puts "Done!"
  end
end
