class CreateServiceNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :service_notes do |t|
      t.references :service_request, null: false, foreign_key: true
      t.references :technician,      null: false, foreign_key: { to_table: :users }
      t.integer    :note_type,       null: false, default: 0
      t.text       :body,            null: false

      t.timestamps
    end

    add_index :service_notes, :note_type
  end
end
