# frozen_string_literal: true

FactoryBot.define do
  sequence(:email) { |n| "email-#{n}@example.com" }

  factory :user do
    email { generate(:email) }
    password { 'test-password' }

    factory :admin do
      before(:create) { |user| user.role = :admin }
    end

    factory :org_admin do
      organization
      before(:create) { |user| user.role = :org_admin }
    end

    factory :employee do
      organization
      before(:create) { |user| user.role = :employee }
    end
  end
end
