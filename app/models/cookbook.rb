class Cookbook < ActiveRecord::Base

  def to_param
    name.downcase.parameterize
  end

end
