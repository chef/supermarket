class GroupMember < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates_presence_of :group
  validates_presence_of :user

  validates :user_id, uniqueness: { scope: [:group_id],
                                    message: 'cannot be added to a group multiple times' }

  # Accessors
  # --------------------
  attr_accessor :user_ids
end
