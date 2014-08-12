json.username @user.username
json.name @user.name
json.company @user.company
json.github Array(@github_usernames)
json.twitter @user.twitter_username
json.irc @user.irc_nickname
json.jira @user.jira_username
json.cookbooks do
  json.set! :owns do
    @owned_cookbooks.each do |cookbook|
      json.set! cookbook.name, api_v1_cookbook_url(cookbook)
    end
  end

  json.set! :collaborates do
    @collaborated_cookbooks.each do |cookbook|
      json.set! cookbook.name, api_v1_cookbook_url(cookbook)
    end
  end

  json.set! :follows do
    @followed_cookbooks.each do |cookbook|
      json.set! cookbook.name, api_v1_cookbook_url(cookbook)
    end
  end
end
