class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :group, presence: true
  validates :user, presence: true

  validates :user_id, uniqueness: { scope: [:group_id],
                                    message: 'cannot be added to a group multiple times' }

  # Accessors
  # --------------------
  attr_accessor :user_ids
end
