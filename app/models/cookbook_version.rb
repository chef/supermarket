class CookbookVersion < ActiveRecord::Base
  belongs_to :cookbook

  validates :license, presence: true
  validates :version, presence: true
  validates :description, presence: true
  validates :cookbook_id, presence: true
end
