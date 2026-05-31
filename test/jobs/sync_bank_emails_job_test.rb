# frozen_string_literal: true

require "test_helper"

class SyncBankEmailsJobTest < ActiveSupport::TestCase
  test "marks account synced and stamps last_synced_at on success" do
    account = create(:gmail_account)

    stub_sync(result: true) do
      freeze_time do
        SyncBankEmailsJob.new.perform(account)
        account.reload
        assert account.sync_synced?
        assert_equal Time.current, account.last_synced_at
      end
    end
  end

  test "marks account failed when service reports auth failure" do
    account = create(:gmail_account)

    stub_sync(result: false) do
      SyncBankEmailsJob.new.perform(account)
    end

    assert account.reload.sync_failed?
    assert_nil account.last_synced_at
  end

  test "marks account failed and re-raises on unexpected error" do
    account = create(:gmail_account)

    stub_sync(raise: StandardError.new("boom")) do
      assert_raises(StandardError) { SyncBankEmailsJob.new.perform(account) }
    end

    assert account.reload.sync_failed?
  end

  private

  # Stubs SyncBankEmailsService#call to return a value or raise, for the block.
  def stub_sync(result: nil, raise: nil)
    original = SyncBankEmailsService.instance_method(:call)
    SyncBankEmailsService.define_method(:call) { raise ? Kernel.raise(raise) : result }
    yield
  ensure
    SyncBankEmailsService.define_method(:call, original)
  end
end
