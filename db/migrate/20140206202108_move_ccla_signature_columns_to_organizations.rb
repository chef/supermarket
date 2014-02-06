class MoveCclaSignatureColumnsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :address_line_1, :string
    add_column :organizations, :address_line_2, :string
    add_column :organizations, :city, :string
    add_column :organizations, :state, :string
    add_column :organizations, :zip, :string
    add_column :organizations, :country, :string

    remove_column :ccla_signatures, :prefix, :string
    remove_column :ccla_signatures, :first_name, :string
    remove_column :ccla_signatures, :middle_name, :string
    remove_column :ccla_signatures, :last_name, :string
    remove_column :ccla_signatures, :suffix, :string
    remove_column :ccla_signatures, :email, :string
    remove_column :ccla_signatures, :phone, :string
    remove_column :ccla_signatures, :company, :string
    remove_column :ccla_signatures, :address_line_1, :string
    remove_column :ccla_signatures, :address_line_2, :string
    remove_column :ccla_signatures, :city, :string
    remove_column :ccla_signatures, :state, :string
    remove_column :ccla_signatures, :zip, :string
    remove_column :ccla_signatures, :country, :string
  end
end
