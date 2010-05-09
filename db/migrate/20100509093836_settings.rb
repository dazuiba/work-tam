class Settings < ActiveRecord::Migration
  def self.up
    create_table "settings", :force => true do |t|
      t.string "name",  :limit => 30, :default => "", :null => false
      t.text   "value"
    end
  end

  def self.down
    drop_table :settings
  end
end
