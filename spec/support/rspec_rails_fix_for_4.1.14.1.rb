# Fix for rspec-rails and rails 4.1.14.1 & 4.2.5.1
# This can be removed as soon as doing so doesn't cause test errors.
# See https://github.com/rspec/rspec-rails/issues/1532

puts 'Rspec::Rails monkeypatched. Investigate updated rspec-rails gem.'
RSpec::Rails::ViewRendering::EmptyTemplatePathSetDecorator.class_eval do
  alias_method :find_all_anywhere, :find_all
end
