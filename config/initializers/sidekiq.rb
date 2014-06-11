Sidekiq.configure_server do
  Supermarket::Application.load_tasks
end
