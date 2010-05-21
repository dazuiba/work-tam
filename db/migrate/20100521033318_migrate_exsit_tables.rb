class MigrateExsitTables < ActiveRecord::Migration
  def self.up
    change_table :dbconfigs do |t|
      t.boolean :disabled, :default=>false
    end
  end

  def self.down
  end
end
