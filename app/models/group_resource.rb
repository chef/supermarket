class GroupResource < ActiveRecord::Base
  belongs_to :group
  belongs_to :resourceable, polymorphic: true

  validates_presence_of :group
  validates_presence_of :resourceable
end
