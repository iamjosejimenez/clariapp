# frozen_string_literal: true

require "test_helper"

class FetchBankEmailsJobTest < ActiveJob::TestCase
  test "ejecuta el sync para cada cuenta activa y omite las que están en error" do
    active = create(:gmail_account, status: "active")
    create(:gmail_account, status: "error")

    synced_ids = []
    original_new = SyncBankEmailsService.method(:new)
    SyncBankEmailsService.singleton_class.send(:define_method, :new) do |account, **_kwargs|
      synced_ids << account.id
      Struct.new(:noop) { def call; end }.new
    end

    FetchBankEmailsJob.new.perform

    assert_equal [ active.id ], synced_ids
  ensure
    SyncBankEmailsService.singleton_class.send(:define_method, :new) do |*args, **kwargs, &block|
      original_new.call(*args, **kwargs, &block)
    end
  end
end
