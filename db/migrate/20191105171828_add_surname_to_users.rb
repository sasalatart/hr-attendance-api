# frozen_string_literal: true

class AddSurnameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :surname, :string, null: false
  end
end
