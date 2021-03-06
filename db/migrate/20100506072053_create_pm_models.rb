class CreatePmModels < ActiveRecord::Migration
  def self.up

    create_table "pm_elements" do |t|
      t.string   "name" , :null => false
      t.string   "title"
      t.integer  :pm_model_id , :null => false  
      t.boolean  "leaf", :default => true
      t.integer  :parent_id
      t.text     :properties
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "pm_models" do |t|
      t.string   "name" , :null => false  
      t.string   "title"
      t.integer  "pm_folder_id", :null => false  
      t.text     :properties
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "pm_folders" do |t|
      t.string   "name" , :null => false  
      t.string   "title"
      t.integer  "parent_id"
      t.integer  "pm_lib_id", :null => false  
      t.boolean  "leaf", :default => nil
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "pm_libs" do |t|
      t.string   "name", :null => false  
      t.string   "title"
      t.integer  "owner_id"
      t.string   "project_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  end

  def self.down
    drop_table :table_name
    drop_table :pm_elements
    drop_table :pm_models
    drop_table :pm_folders
    drop_table :pm_libs
  end
end
