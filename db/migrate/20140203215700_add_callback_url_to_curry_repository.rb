class AddCallbackUrlToCurryRepository < ActiveRecord::Migration
  def change
    add_column :curry_repositories, :callback_url, :string
  end
end
