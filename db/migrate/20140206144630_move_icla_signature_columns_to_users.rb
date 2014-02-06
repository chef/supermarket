class MoveIclaSignatureColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :address_line_1, :string
    add_column :users, :address_line_2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zip, :string
    add_column :users, :country, :string

    remove_column :users, :primary_email_id, :integer
    remove_column :users, :username, :string
    remove_column :users, :prefix, :string
    remove_column :users, :middle_name, :string
    remove_column :users, :suffix, :string

    remove_column :icla_signatures, :prefix, :string
    remove_column :icla_signatures, :first_name, :string
    remove_column :icla_signatures, :middle_name, :string
    remove_column :icla_signatures, :last_name, :string
    remove_column :icla_signatures, :suffix, :string
    remove_column :icla_signatures, :email, :string
    remove_column :icla_signatures, :phone, :string
    remove_column :icla_signatures, :company, :string
    remove_column :icla_signatures, :address_line_1, :string
    remove_column :icla_signatures, :address_line_2, :string
    remove_column :icla_signatures, :city, :string
    remove_column :icla_signatures, :state, :string
    remove_column :icla_signatures, :zip, :string
    remove_column :icla_signatures, :country, :string
  end
end
