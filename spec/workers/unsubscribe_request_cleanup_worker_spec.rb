require 'spec_helper'

describe UnsubscribeRequestCleanupWorker do
  it 'deletes UnsubscribeRequests older than 6 months' do
    Timecop.freeze(7.months.ago) do
      create(:unsubscribe_request)
      create(:unsubscribe_request)
      create(:unsubscribe_request)
    end

    Timecop.freeze(1.day.ago) do
      create(:unsubscribe_request)
    end

    expect do
      Sidekiq::Testing.inline! do
        UnsubscribeRequestCleanupWorker.new.perform
      end
    end.to change(UnsubscribeRequest, :count).by(-3)
  end
end
