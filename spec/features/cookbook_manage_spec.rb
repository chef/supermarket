require 'spec_feature_helper'

describe "updating a cookbook's issues and source urls" do
  before { sign_in create(:user) }

  it 'saves the source and issues urls' do
    owner = create(:user)
    cookbook = create(:cookbook, owner: owner)

    visit cookbook_path(cookbook)

    within '.cookbook_show_sidebar' do
      follow_relation 'edit-cookbook-urls'
      fill_in 'cookbook_source_url', with: 'http://example.com/source'
      fill_in 'cookbook_issues_url', with: 'http://example.com/tissues'
      submit_form
    end

    expect(find('.source-url')[:href]).to eql('http://example.com/source')
    expect(find('.issues-url')[:href]).to eql('http://example.com/tissues')
  end

  it 'displays an error message when invalid urls are entered' do
    owner = create(:user)
    cookbook = create(:cookbook, owner: owner)

    visit cookbook_path(cookbook)

    within '.cookbook_show_sidebar' do
      follow_relation 'edit-cookbook-urls'
      fill_in 'cookbook_source_url', with: 'example'
      fill_in 'cookbook_source_url', with: 'example'
    end

    expect(find('.edit_cookbook').all('.error').count).to eql(2)
  end
end
