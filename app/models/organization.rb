# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :attendances, through: :users

  validates :name, presence: true,
                   uniqueness: { allow_blank: true, case_sensitive: false }
end
