class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :service_request, null: false, foreign_key: true
      t.references :sender,          null: false, foreign_key: { to_table: :users }
      t.text       :body,            null: false

      t.timestamps
    end
  end
end
