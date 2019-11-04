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
#

EMAIL_REGEX = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i.freeze

class User < ApplicationRecord
  rolify
  has_secure_password

  before_save :downcase_email
  after_create :assign_default_role

  validates :email, presence: true,
                    uniqueness: { allow_blank: true, case_sensitive: false },
                    format: { allow_blank: true, with: EMAIL_REGEX }

  private

  def downcase_email
    self.email = email.downcase if will_save_change_to_attribute?(:email)
  end

  def assign_default_role
    add_role(:employee) if roles.blank?
  end
end
