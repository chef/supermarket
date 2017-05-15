class Hit < ApplicationRecord
  validates :label, presence: true
  validates :total,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
