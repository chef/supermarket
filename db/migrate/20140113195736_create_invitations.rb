class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.references :organization, index: true
      t.string     :email
      t.string     :token
      t.boolean    :admin
      t.boolean    :accepted

      t.timestamps
    end
  end
end
