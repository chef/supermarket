require 'byebug'
require 'i18n'

RSpec.configure do |config|
  config.libs = %w(app/authorizers app/models lib)

  I18n.load_path.unshift(File.expand_path('config/locales/en.yml'))
  I18n.enforce_available_locales = true
end
