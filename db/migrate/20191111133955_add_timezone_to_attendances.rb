# frozen_string_literal: true

class AddTimezoneToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :timezone, :string, null: false
  end
end
