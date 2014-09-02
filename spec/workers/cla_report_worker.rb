require 'spec_helper'

describe ClaReportWorker do
  before { create(:icla_signature) }

  it 'creates a new ClaReport' do
    expect do
      ClaReportWorker.new.perform
    end.to change(ClaReport, :count).by(1)
  end

  it 'sends a CLA Report email' do
    expect do
      ClaReportWorker.new.perform
    end.to change(ActionMailer::Base.deliveries, :count).by(1)
  end
end
