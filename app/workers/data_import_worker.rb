#
# Responsible for migrating data from the Opscode Community Site to Supermarket
#
class DataImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence do
    hours = (0..23).step(3)

    daily.hour_of_day(*hours)
  end

  #
  # Invokes the supermarket:migrate Rake task
  #
  def perform
    return unless ENV['COMMUNITY_SITE_DATABASE_URL'].present?

    migration = Rake::Task['supermarket:migrate']

    supermarket_tasks(migration).each(&:reenable)

    migration.invoke
  end

  private

  def supermarket_tasks(task)
    ([task] + task.prerequisite_tasks.map { |t| supermarket_tasks(t) }).
      flatten.
      uniq(&:name).
      select { |t| t.name.include?('supermarket') }
  end
end
