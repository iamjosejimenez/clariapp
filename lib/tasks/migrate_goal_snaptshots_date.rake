namespace :data_migration do
  desc "Migrate GoalSnapshot create_date to extraction_date"
  task migrate_goal_snapshots_date: :environment do
    Goal.find_each do |goal|
      snapshots = goal.goal_snapshots
      next if snapshots.empty?
      puts "Processing Goal #{goal.id} with #{snapshots.count} snapshots"

      snapshots_by_date = snapshots.group_by { |snapshot| snapshot.created_at.to_date }
      snapshots_by_date.each do |date, snapshots_on_date|
        puts "Processing snapshots for date: #{date}"

        latest_snapshot = snapshots_on_date.max_by { |s| s.created_at }
        rest_snapshots =  snapshots_on_date.reject { |s| s == latest_snapshot }

        rest_snapshots.each do |snapshot|
          snapshot.destroy
          puts "Deleted GoalSnapshot #{snapshot.id} created at #{snapshot.created_at}"
        end

        puts "Keeping latest snapshot for date #{date}: #{latest_snapshot.id}"

        latest_snapshot.update!(extraction_date: date)
      end
    rescue StandardError => e
      puts "Failed to update GoalSnapshot #{snapshot.id}: #{e.message}"
      next
    end
    puts "Done!"
  end
end
