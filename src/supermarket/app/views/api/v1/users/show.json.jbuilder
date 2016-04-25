json.username @user.username
json.name @user.name
json.company @user.company
json.github Array(@github_usernames)
json.twitter @user.twitter_username
json.email @user.email
json.irc @user.irc_nickname
json.jira @user.jira_username
json.authorized_to_contribute @user.authorized_to_contribute?
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

json.tools do
  json.set! :owns do
    @owned_tools.each do |tool|
      json.set! tool.name, api_v1_tool_url(tool.slug)
    end
  end

  json.set! :collaborates do
    @collaborated_tools.each do |tool|
      json.set! tool.name, api_v1_tool_url(tool.slug)
    end
  end
end
