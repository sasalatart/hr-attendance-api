# frozen_string_literal: true

class AttendanceSerializer < ActiveModel::Serializer
  attributes :id, :employee_id, :employee_fullname, :entered_at, :left_at, :updated_at, :created_at

  def employee_fullname
    employee = object.employee
    %i[name surname second_surname].map { |attribute| employee[attribute] }.compact.join(' ')
  end
end
