class CreateOrganizationUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :organization_users do |t|
      t.references :user, index: true
      t.references :organization, index: true
      t.boolean    :admin

      t.timestamps
    end
  end
end
