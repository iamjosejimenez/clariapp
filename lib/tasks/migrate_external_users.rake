# lib/tasks/migrate_external_users.rake
namespace :data_migration do
  desc "Migrar FintualUser a ExternalAccount"
  task migrate_external_users: :environment do
    provider = "fintual" # el actual
    FintualUser.find_each do |fintual_user|
      external_account = ExternalAccount.create!(
        user_id: fintual_user.user_id,
        provider: provider,
        username: fintual_user.email,
        access_token: fintual_user.token,
        created_at: fintual_user.created_at,
        updated_at: fintual_user.updated_at,
        status: "active",
      )

      fintual_user.goals.update_all("external_account_id = #{external_account.id}")
    end
  end
end
