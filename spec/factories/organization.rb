# frozen_string_literal: true

FactoryBot.define do
  sequence(:name) { |n| "name-#{n}" }

  factory :organization do
    name { generate(:name) }

    transient do
      org_admin_count { 0 }
      employee_count { 0 }
    end

    after(:create) do |organization, options|
      options.org_admin_count&.times do
        create(:org_admin, organization: organization)
      end

      options.employee_count&.times do
        create(:employee, organization: organization)
      end
    end
  end
end
