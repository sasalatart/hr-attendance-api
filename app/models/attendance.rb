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
  validate :left_at, :only_one_open_at_the_time
  validate :left_at, :only_last_may_be_open

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

  def only_one_open_at_the_time
    open_ids = Attendance.where(employee_id: employee_id, left_at: nil).pluck(:id)
    return if open_ids.empty? || (open_ids.size == 1 && open_ids.include?(id))

    errors.add(:base, :only_one_open_at_the_time)
  end

  def only_last_may_be_open
    return if left_at

    after_count = Attendance.where(employee_id: employee_id)
                            .where('entered_at > ?', entered_at)
                            .count

    return if after_count.zero?

    errors.add(:base, :only_last_may_be_open)
  end

  def only_for_employees
    return unless will_save_change_to_attribute?(:employee_id)
    return if employee&.employee?

    errors.add(:employee_id, :only_for_employees)
  end
end
