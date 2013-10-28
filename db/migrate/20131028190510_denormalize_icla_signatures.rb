class DenormalizeIclaSignatures < ActiveRecord::Migration
  def change
    add_column :icla_signatures, :prefix, :string
    add_column :icla_signatures, :first_name, :string
    add_column :icla_signatures, :middle_name, :string
    add_column :icla_signatures, :last_name, :string
    add_column :icla_signatures, :suffix, :string

    add_column :icla_signatures, :email, :string
    add_column :icla_signatures, :phone, :string
    add_column :icla_signatures, :company, :string

    add_column :icla_signatures, :address_line_1, :string
    add_column :icla_signatures, :address_line_2, :string
    add_column :icla_signatures, :city, :string
    add_column :icla_signatures, :state, :string
    add_column :icla_signatures, :zip, :string
    add_column :icla_signatures, :country, :string
  end
end
