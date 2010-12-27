class ChangeMessageOnErrors < ActiveRecord::Migration
  def self.up
    change_column :errors, :message, :text
  end

  def self.down
    change_column :errors, :message, :string
  end
end