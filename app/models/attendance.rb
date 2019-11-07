# frozen_string_literal: true

# == Schema Information
#
# Table name: attendances
#
#  id          :uuid             not null, primary key
#  employee_id :uuid
#  entered_at  :datetime         not null
#  left_at     :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Attendance < ApplicationRecord
  belongs_to :employee, class_name: :User

  validates :entered_at, presence: true

  validates_datetime :entered_at
  validates_datetime :left_at, after: :entered_at,
                               allow_nil: true

  validate :employee, :only_for_employees
  validate :left_at, :only_one_left_at_per_employee_per_day
  validate :entered_at, :only_one_entered_at_per_employee_per_day

  private

  def only_for_employees
    return unless will_save_change_to_attribute?(:employee_id)
    return if employee&.employee?

    errors.add(:employee_id, :only_for_employees)
  end

  def only_one_per_employee_per_day(attribute_name)
    value = self[attribute_name]
    bod = value.beginning_of_day
    eod = value.end_of_day
    existing_count = Attendance.where(
      "#{attribute_name} >= ? and #{attribute_name} <= ?", bod, eod
    ).where(employee_id: employee_id).count

    return if new_record? && existing_count.zero?
    return if persisted? && existing_count == 1

    errors.add(attribute_name, :only_one_per_employee_per_day)
  end

  def only_one_left_at_per_employee_per_day
    only_one_per_employee_per_day(:left_at) if left_at && will_save_change_to_attribute?(:left_at)
  end

  def only_one_entered_at_per_employee_per_day
    only_one_per_employee_per_day(:entered_at) if will_save_change_to_attribute?(:entered_at)
  end
end
