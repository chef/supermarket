class GroupResource < ApplicationRecord
  belongs_to :group
  belongs_to :resourceable, polymorphic: true

  validates :group, presence: true
  validates :resourceable, presence: true
end
