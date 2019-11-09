# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email
    name
    surname { 'Surname' }
    password { 'test-password' }

    transient do
      num_attendances { 0 }
    end

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

      after(:create) do |user, options|
        bod = DateTime.now.beginning_of_day
        options.num_attendances.times do |index|
          entered_at = bod - (index + 1).days
          left_at = entered_at + 9.hours
          create(:attendance, employee: user, entered_at: entered_at, left_at: left_at)
        end
      end
    end
  end
end
