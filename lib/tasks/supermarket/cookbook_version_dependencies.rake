namespace :supermarket do
  desc 'Queues jobs to rebuild each cookbook version archive'
  task :rebuild_cookbook_version_dependencies => :environment do
    processed_ids = VerifiedCookbookVersion.pluck(:cookbook_version_id)
    base_scope = CookbookVersion.where('legacy_id IS NOT NULL')

    if processed_ids.any?
      queue_scope = base_scope.where('id NOT IN (?)', processed_ids)
    else
      queue_scope = base_scope
    end

    queue_scope.pluck(:id).each do |id|
      CookbookVersionDependenciesRebuilder.perform_async(id)
    end
  end
end
