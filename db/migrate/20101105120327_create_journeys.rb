class CreateJourneys < ActiveRecord::Migration
  def self.up
    create_table :journeys, :force => true do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :journeys
  end
end
