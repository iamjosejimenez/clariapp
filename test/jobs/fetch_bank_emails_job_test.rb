# frozen_string_literal: true

require "test_helper"

class FetchBankEmailsJobTest < ActiveJob::TestCase
  test "encola un sync job por cada cuenta activa y omite las que están en error" do
    active = create(:gmail_account, status: "active")
    create(:gmail_account, status: "error")

    assert_enqueued_with(job: SyncBankEmailsJob, args: [ active ]) do
      FetchBankEmailsJob.new.perform
    end
    assert_enqueued_jobs 1, only: SyncBankEmailsJob
  end
end
