class CreateDmSqls < ActiveRecord::Migration
  def self.up
    create_table :dm_sqls do |t|
      t.string "title"
      t.text   "content"
      t.integer "owner_id"
      t.timestamps
    end
  end

  def self.down
    drop_table :dm_sqls
  end
end
