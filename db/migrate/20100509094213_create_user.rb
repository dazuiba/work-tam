class CreateUser < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.string   "login"
      t.string   "nickname"
      t.string   "realname"
      t.string   "password"
      t.integer  "disabled",                  :default => 0, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "email"
      t.integer  "admin",        :limit => 1
      t.string   "department"
      t.integer  "report_to_id"
      t.text     "config"
    end

    add_index "users", ["login"], :name => "login", :unique => true
    
  end

  def self.down   
    drop_table :users
  end
end
