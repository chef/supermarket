class CreateCurryUnknownCommitters < ActiveRecord::Migration
  def change
    create_table :curry_unknown_committers do |t|
      t.string :login
      t.string :email

      t.timestamps
    end
  end
end
