require 'spec_feature_helper'

describe 'cookbook following' do
  before do
    sign_in(create(:user))
    owner = create(:user)
    cookbook = create(:cookbook, owner: owner)

    visit '/'
    follow_relation 'cookbooks'

    within '.recently-updated' do
      follow_relation 'cookbook'
    end
  end

  it 'allows a user to follow a cookbook' do
    follow_relation 'follow'

    expect(page).to have_xpath("//a[starts-with(@rel, 'unfollow')]")
  end

  it 'allows a user to unfollow a cookbook' do
    follow_relation 'follow'
    follow_relation 'unfollow'

    expect(page).to have_xpath("//a[starts-with(@rel, 'follow')]")
  end
end
