Sidekiq.configure_server do |config|
  Supermarket::Application.load_tasks

  config.on(:shutdown) do
    ::CookbookVersion.
      where(verification_state: 'in_progress').
      update_all(verification_state: 'pending')
  end
end
