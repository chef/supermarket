module Supermarket
  module Migration
    module RemoveDuplicateCookbookDependencies
      def self.call
        query = %(
          SELECT cookbook_version_id, name, version_constraint, count(*) as cnt
          FROM cookbook_dependencies
          GROUP BY cookbook_version_id, name, version_constraint
        )

        rows = ActiveRecord::Base.connection.execute(query).select do |row|
          row['cnt'].to_i > 1
        end

        duplicate_ids = rows.flat_map do |row|
          CookbookDependency.where(
            name: row['name'],
            version_constraint: row['version_constraint'],
            cookbook_version_id: row['cookbook_version_id']
          ).limit(row['cnt'].to_i - 1).pluck(:id)
        end

        CookbookDependency.where(id: duplicate_ids).delete_all
      end
    end
  end
end
