class CreateServiceRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :service_requests do |t|
      t.references :customer,   null: false, foreign_key: { to_table: :users }
      t.bigint     :technician_id                         # nullable, managed via belongs_to optional:
      t.string     :device_brand,       null: false
      t.string     :device_model,       null: false
      t.string     :serial_number
      t.text       :issue_description,  null: false
      t.string     :contact_info,       null: false
      t.integer    :status,             null: false, default: 0
      t.datetime   :assigned_at
      t.datetime   :completed_at

      t.timestamps
    end

    add_index :service_requests, :technician_id
    add_index :service_requests, :status
    add_foreign_key :service_requests, :users, column: :technician_id
  end
end
