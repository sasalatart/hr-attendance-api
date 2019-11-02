# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'user@example.org' }
    password { 'test-password' }
  end
end
