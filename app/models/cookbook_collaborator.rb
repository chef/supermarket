class CookbookCollaborator < ActiveRecord::Base
  belongs_to :cookbook
  belongs_to :user
end
