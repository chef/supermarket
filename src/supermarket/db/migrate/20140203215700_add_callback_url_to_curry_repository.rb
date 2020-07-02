class AddCallbackUrlToCurryRepository < ActiveRecord::Migration[4.2]
  def change
    add_column :curry_repositories, :callback_url, :string
  end
end
