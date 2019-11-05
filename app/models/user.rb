# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  email           :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  role            :integer          not null
#  organization_id :uuid
#

EMAIL_REGEX = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i.freeze

class User < ApplicationRecord
  ROLES = { admin: 0, org_admin: 1, employee: 2 }.freeze

  has_secure_password

  enum role: ROLES

  before_save :downcase_email

  belongs_to :organization, optional: true

  validates :role, presence: true

  validates :email, presence: true,
                    uniqueness: { allow_blank: true, case_sensitive: false },
                    format: { allow_blank: true, with: EMAIL_REGEX }

  validate :organization_present_for_non_admins_only

  private

  def downcase_email
    self.email = email.downcase if will_save_change_to_attribute?(:email)
  end

  def organization_present_for_non_admins_only
    return if (admin? && !organization_id) || (!admin? && organization_id)

    errors.add(:organization_id, :organization_consistency)
  end
end
