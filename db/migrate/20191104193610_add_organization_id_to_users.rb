# frozen_string_literal: true

class AddOrganizationIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :organization, type: :uuid, foreign_key: true
  end
end
