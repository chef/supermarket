+++
title = "Supermarket Logs"
draft = false
gh_repo = "supermarket"
aliases = ["/supermarket_logs.html", "/supermarket_logs/"]

[menu]
  [menu.supermarket]
    title = "Log Files"
    identifier = "supermarket/server/Log Files"
    parent = "supermarket/server"
    weight = 60
+++

The Chef Supermarket omnibus package does not log Ruby on Rails messages by default. To enable debug logging, edit the `/opt/supermarket/embedded/service/supermarket/config/environments/production.rb` file and set the `config.log_level` setting to `:debug`:

```ruby
config.logger = Logger.new('/var/log/supermarket/rails/rails.log')
config.logger.level = 'DEBUG'
config.log_level = :debug
```

Save the file, and then restart the Ruby on Rails service:

```bash
supermarket-ctl restart rails
```
