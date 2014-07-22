class CurryRepositoryAttributesNotNullable < ActiveRecord::Migration
  def change
    change_column :curry_repositories, :owner, :string, null: false
    change_column :curry_repositories, :name, :string, null: false
    change_column :curry_repositories, :callback_url, :string, null: false
  end
end
