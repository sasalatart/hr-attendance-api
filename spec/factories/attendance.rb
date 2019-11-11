# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    employee { create(:employee) }
    entered_at { 1.hour.ago }
    left_at { DateTime.now }
    timezone { 'America/Mexico_City' }
  end
end
