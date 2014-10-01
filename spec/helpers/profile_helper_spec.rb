require 'spec_helper'

describe ProfileHelper do
  context '#email_preference' do
    it 'should output an unchecked checkbox if the user does not have the preference' do
      user = create(:user)
      user.email_preferences.delete(:new_version)
      user.save
      allow(helper).to receive(:current_user) { user }
      div = '<div><input id="user_email_preferences_new_version" name="user[email_preferences][]" type="checkbox" value="new_version" /><label for="user_email_preferences_new_version">New cookbook version</label></div>'
      result = helper.email_preference(:email_preferences, :new_version)
      expect(result).to eql(div.squish)
    end

    it 'should output a checked checkbox if the user has the preference' do
      user = create(:user, email_preferences: [:new_version])
      allow(helper).to receive(:current_user) { user }
      div = '<div><input checked="checked" id="user_email_preferences_new_version" name="user[email_preferences][]" type="checkbox" value="new_version" /><label for="user_email_preferences_new_version">New cookbook version</label></div>'
      result = helper.email_preference(:email_preferences, :new_version)
      expect(result).to eql(div.squish)
    end
  end
end
