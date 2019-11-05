# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :role,
             :organization_id,
             :email,
             :name,
             :surname,
             :second_surname,
             :updated_at,
             :created_at
end
