require 'spec_feature_helper'

describe 'cookbook collaboration' do
  let(:suzie) { create(:user) }
  let(:sally) { create(:user) }
  let(:cookbook) { create(:cookbook, owner: sally) }

  before do
    create(:cookbook_collaborator, cookbook: cookbook, user: suzie)
  end

  def navigate_to_cookbook
    visit '/'
    follow_relation 'cookbooks'

    within '.recently-updated' do
      follow_relation 'cookbook'
    end
  end

  it 'allows the owner to remove a collaborator' do
    sign_in(sally)
    navigate_to_cookbook

    find('[rel*=remove-cookbook-collaborator]').trigger('click')
    expect(page).to have_no_css('div.gravatar-container')
  end

  it 'allows a collaborator to remove herself' do
    sign_in(suzie)
    navigate_to_cookbook

    find('[rel*=remove-cookbook-collaborator]').trigger('click')
    expect(page).to have_no_css('div.gravatar-container')
  end
end
