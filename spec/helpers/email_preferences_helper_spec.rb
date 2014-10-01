require 'spec_helper'

describe EmailPreferencesHelper do
  it 'should output pretty names when given a short name' do
    expect(helper.pretty_email_name(:new_version)).to eql('New cookbook version')
    expect(helper.pretty_email_name(:deleted)).to eql('Cookbook deleted')
    expect(helper.pretty_email_name(:deprecated)).to eql('Cookbook deprecated')
  end

  it 'should do the right thing when given strings instead of symbols' do
    expect(helper.pretty_email_name('new_version')).to eql('New cookbook version')
    expect(helper.pretty_email_name('deleted')).to eql('Cookbook deleted')
    expect(helper.pretty_email_name('deprecated')).to eql('Cookbook deprecated')
  end
end
