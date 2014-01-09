module FeatureHelpers
  def sign_in_with_github
    visit '/'
    click_link 'Sign In'
    click_link 'GitHub'
  end
end
