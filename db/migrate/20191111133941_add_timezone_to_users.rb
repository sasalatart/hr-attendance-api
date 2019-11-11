# frozen_string_literal: true

class AddTimezoneToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :timezone, :string, null: false
  end
end
