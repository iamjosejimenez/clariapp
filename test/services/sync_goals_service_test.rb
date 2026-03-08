# frozen_string_literal: true

require "test_helper"

class SyncGoalsServiceTest < ActiveSupport::TestCase
  FakeFintualClient = Struct.new(:payload) do
    def fetch_goals
      payload
    end
  end

  test "no sobreescribe metas de otra cuenta externa con el mismo external_id" do
    original_account = create(:external_account, provider: "fintual")
    original_goal = create(
      :goal,
      external_account: original_account,
      external_id: "goal-123",
      name: "Meta original"
    )

    synced_account = create(:external_account, provider: "fintual")
    payload = [
      {
        id: "goal-123",
        name: "Meta sincronizada",
        created_at: Time.current.iso8601,
        nav: "1000.0",
        profit: "100.0",
        not_net_deposited: "900.0",
        deposited: "950.0",
        withdrawn: "50.0"
      }
    ]

    original_new = FintualApi.method(:new)
    FintualApi.singleton_class.send(:define_method, :new) do |_external_account|
      FakeFintualClient.new(payload)
    end

    SyncGoalsService.new(synced_account).call

    assert_equal "Meta original", original_goal.reload.name

    synced_goal = synced_account.goals.find_by!(external_id: "goal-123")
    assert_equal "Meta sincronizada", synced_goal.name
  ensure
    FintualApi.singleton_class.send(:define_method, :new) do |*args, **kwargs, &block|
      original_new.call(*args, **kwargs, &block)
    end
  end
end
