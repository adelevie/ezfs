class CreateFilings < ActiveRecord::Migration
  def change
    create_table :filings do |t|
      t.string :docket_number, null: false
      t.string :name_of_filer, null: false
      t.string :type_of_filing, null: false
      t.string :fcc_url, null: false
      t.string :fcc_id, null: false
      t.string :citation, null: false
      t.datetime :date_received, null: false
    end
  end
end
