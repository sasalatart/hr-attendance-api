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

  validates_datetime :entered_at, before: -> { 1.second.from_now }

  validates_datetime :left_at, after: :entered_at,
                               before: -> { 1.second.from_now },
                               allow_nil: true

  validate :employee, :only_for_employees
  validate :entered_at, :no_overlapping
  validate :entered_at, :only_one_entered_at_per_employee_per_day
  validate :left_at, :only_one_left_at_per_employee_per_day

  private

  def overlapping_count
    Attendance.where(employee_id: employee_id).where(
      'entered_at >= ? and entered_at <= ?', entered_at, left_at
    ).or(Attendance.where(
           'left_at >= ? and left_at <= ?', entered_at, left_at
         )).or(Attendance.where(
                 'entered_at <= ? and left_at >= ?', entered_at, left_at
               )).count
  end

  def no_overlapping
    return if new_record? && overlapping_count.zero?
    return if persisted? && overlapping_count == 1

    errors.add(:base, :no_overlapping)
  end

  def only_for_employees
    return unless will_save_change_to_attribute?(:employee_id)
    return if employee&.employee?

    errors.add(:employee_id, :only_for_employees)
  end

  def existing_daily_count_for(attribute_name)
    value = self[attribute_name]
    bod = value.beginning_of_day
    eod = value.end_of_day
    Attendance.where(employee_id: employee_id).where(
      "#{attribute_name} >= ? and #{attribute_name} <= ?", bod, eod
    ).count
  end

  def only_one_left_at_per_employee_per_day
    return unless left_at && will_save_change_to_attribute?(:left_at)
    return if existing_daily_count_for(:left_at).zero?

    errors.add(:left_at, :only_one_per_employee_per_day)
  end

  def only_one_entered_at_per_employee_per_day
    return unless will_save_change_to_attribute?(:entered_at)

    existing_count = existing_daily_count_for(:entered_at)
    return if existing_count.zero? && new_record?
    return if existing_count == 1 && persisted?

    errors.add(:entered_at, :only_one_per_employee_per_day)
  end
end
