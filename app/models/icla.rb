class Icla < ActiveRecord::Base
  validates_uniqueness_of :version
end
