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
#  timezone    :string           not null
#

class Attendance < ApplicationRecord
  belongs_to :employee, class_name: :User

  validates :entered_at, presence: true

  validates_datetime :entered_at, before: -> { 1.second.from_now }

  validates_datetime :left_at, after: :entered_at,
                               before: -> { 1.second.from_now },
                               allow_nil: true

  validates :timezone, presence: true,
                       inclusion: { in: ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.name } }

  validate :employee, :only_for_employees
  validate :entered_at, :no_overlapping
  validate :entered_at, :only_one_entered_at_per_employee_per_day
  validate :left_at, :only_one_left_at_per_employee_per_day

  private

  def overlapping_ids
    employee_attendances = Attendance.where(employee_id: employee_id)
    employee_attendances.where(
      'entered_at >= ? and entered_at <= ?', entered_at, left_at
    ).or(employee_attendances.where(
           'left_at >= ? and left_at <= ?', entered_at, left_at
         )).or(employee_attendances.where(
                 'entered_at <= ? and left_at >= ?', entered_at, left_at
               )).pluck(:id)
  end

  def no_overlapping
    ids = overlapping_ids
    return if ids.empty? || (ids.size == 1 && ids.include?(id))

    errors.add(:base, :no_overlapping)
  end

  def only_for_employees
    return unless will_save_change_to_attribute?(:employee_id)
    return if employee&.employee?

    errors.add(:employee_id, :only_for_employees)
  end

  def no_other_in_same_day?(attribute_name)
    value = self[attribute_name]
    bod = value.beginning_of_day
    eod = value.end_of_day
    ids = Attendance.where(employee_id: employee_id).where(
      "#{attribute_name} >= ? and #{attribute_name} <= ?", bod, eod
    ).pluck(:id)
    ids.empty? || ids.size == 1 && ids.include?(id)
  end

  def only_one_left_at_per_employee_per_day
    return unless left_at && will_save_change_to_attribute?(:left_at)
    return if no_other_in_same_day?(:left_at)

    errors.add(:left_at, :only_one_per_employee_per_day)
  end

  def only_one_entered_at_per_employee_per_day
    return unless will_save_change_to_attribute?(:entered_at)
    return if no_other_in_same_day?(:entered_at)

    errors.add(:entered_at, :only_one_per_employee_per_day)
  end
end
