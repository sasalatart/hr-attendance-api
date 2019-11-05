# frozen_string_literal: true

FactoryBot.define do
  sequence(:email) { |n| "email-#{n}@example.com" }
  sequence(:name) { |n| "name-#{n}" }
end
