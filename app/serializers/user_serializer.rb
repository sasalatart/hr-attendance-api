# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :role,
             :organization_id,
             :last_attendance,
             :email,
             :name,
             :surname,
             :second_surname,
             :updated_at,
             :created_at

  def last_attendance
    return nil unless object.employee?

    attendance = object.attendances.order(entered_at: :asc).last
    attendance && AttendanceSerializer.new(attendance).as_json
  end
end
