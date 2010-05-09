class CreatePmModels < ActiveRecord::Migration
  def self.up
    create_table :pm_models do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :pm_models
  end
end
