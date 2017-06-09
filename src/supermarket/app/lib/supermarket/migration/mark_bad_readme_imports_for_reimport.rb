module Supermarket
  module Migration
    module MarkBadReadmeImportsForReimport
      def self.call
        CookbookVersion.where('readme like ?', '%ctime=%').each do |cv|
          cv.record_timestamps = false

          cv.transaction do
            cv.dependencies_imported = false
            cv.cookbook_dependencies.each(&:destroy)
            cv.supported_platforms = []
            cv.save!
          end
        end
      end
    end
  end
end
