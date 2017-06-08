module Exportable
  require 'csv'

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def as_csv
      CSV.generate do |csv|
        csv << column_names
        find_each do |item|
          csv << item.attributes.values_at(*column_names)
        end
      end
    end
  end
end
