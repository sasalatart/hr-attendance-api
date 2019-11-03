# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :updated_at, :created_at
end
