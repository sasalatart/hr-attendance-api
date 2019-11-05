class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name, index: { unique: true }, null: false

      t.timestamps
    end
  end
end
