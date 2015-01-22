class AddTimestampsToFilings < ActiveRecord::Migration
  def change_table
    add_timestamps(:filings)
  end
end
