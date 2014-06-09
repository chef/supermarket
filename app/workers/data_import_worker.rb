#
# Responsible for migrating data from the Opscode Community Site to Supermarket
#
class DataImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence do
    daily.hour_of_day(3, 9, 15, 21)
  end

  #
  # Invokes the supermarket:migrate Rake task
  #
  def perform
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
