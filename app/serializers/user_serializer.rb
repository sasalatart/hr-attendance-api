# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :role, :organization_id, :email, :updated_at, :created_at
end
