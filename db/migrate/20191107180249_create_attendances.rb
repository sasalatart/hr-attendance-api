# frozen_string_literal: true

class CreateAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :attendances, id: :uuid do |t|
      t.references :employee, type: :uuid, foreign_key: { to_table: :users }
      t.datetime :entered_at, null: false
      t.datetime :left_at

      t.timestamps
    end

    add_index :attendances, :entered_at
    add_index :attendances, :left_at
  end
end
