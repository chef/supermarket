require 'spec_feature_helper'

describe 'Inviting people to sign a CCLA' do

  it 'sends invited users an email prompting them to sign the CCLA' do
    create(:ccla)
    sign_in_with_github
    sign_ccla
    click_link 'View Profile'
    click_link 'Invite Contributors'

    pending "Fill out 'Invite Contributors Form'"
  end

end
