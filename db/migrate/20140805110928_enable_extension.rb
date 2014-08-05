class EnableExtension < ActiveRecord::Migration
  def change
    enable_extension 'plpgsql'
    enable_extension 'pg_trgm'
  end
end
