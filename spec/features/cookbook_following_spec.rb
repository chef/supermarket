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

  it 'allows a user to follow a cookbook', use_poltergeist: true do
    within '.cookbook_show_content' do
      follow_relation 'follow'
    end

    expect(page).to have_xpath("//a[starts-with(@rel, 'unfollow')]")
  end

  it 'allows a user to unfollow a cookbook', use_poltergeist: true do
    within '.cookbook_show_content' do
      follow_relation 'follow'
    end

    within '.cookbook_show_content' do
      follow_relation 'unfollow'
    end

    expect(page).to have_xpath("//a[starts-with(@rel, 'follow')]")
  end
end
