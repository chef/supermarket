class CreateIclaSignatures < ActiveRecord::Migration[4.2]
  def change
    create_table :icla_signatures do |t|
      t.references :user, index: true
      t.datetime :signed_at
    end
  end
end
