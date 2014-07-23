class AdjustCookbookUpdatedAtDates < ActiveRecord::Migration
  def change
    Cookbook.all.each do |cookbook|
      latest_version_creation_date = cookbook.cookbook_versions.
        order('created_at DESC').first.try(:created_at)

      next unless latest_version_creation_date

      cookbook.updated_at = latest_version_creation_date
      cookbook.save(validate: false)
    end
  end
end
