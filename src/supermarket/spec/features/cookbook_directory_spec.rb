require 'spec_helper'

describe 'cookbook directory' do
  before do
    create_list(:cookbook, 5)

    visit '/'

    within '.appnav' do
      click_link 'Cookbooks'
    end
  end

  it 'lists the five most recently updated cookbooks' do
    within '.recently-updated' do
      expect(all('.simple_listing li').size).to eql(5)
    end
  end

  it 'lists the five most followed cookbooks' do
    within '.most-followed' do
      expect(all('.simple_listing li').size).to eql(5)
    end
  end

  it 'shows link for cookbook adoptions' do
    within '.learn_about_cookbooks_content' do
      expect(page).to have_content('How do I adopt a cookbook?')
      click_link('list of adoptable cookbooks')
    end
    expect(page).to have_content('Cookbooks Available for Adoption')
  end
end
