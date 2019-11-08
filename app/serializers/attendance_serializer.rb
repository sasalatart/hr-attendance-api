# frozen_string_literal: true

class AttendanceSerializer < ActiveModel::Serializer
  attributes :id, :employee_id, :entered_at, :left_at, :updated_at, :created_at
end
