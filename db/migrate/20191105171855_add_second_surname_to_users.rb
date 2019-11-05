# frozen_string_literal: true

class AddSecondSurnameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :second_surname, :string
  end
end
