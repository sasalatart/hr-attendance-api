# frozen_string_literal: true

DEFAULT_PASSWORD = 'napoleon'
total_organizations = 5
org_admins_per_organization = 5
employees_per_organization = 35

def common_user_params
  {
    name: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    password: DEFAULT_PASSWORD
  }
end

def add_attendances_to(employee)
  30.times do |index|
    bod = (index + 1).days.ago.beginning_of_day

    next if bod.saturday? || bod.sunday?

    entered_at = bod + 9.hours + (rand * 30).minutes
    left_at = entered_at + 9.hours + (rand * 30).minutes
    employee.attendances.create!(entered_at: entered_at, left_at: left_at)
  end
end

User.create!({ role: :admin,
               email: 'admin@example.org' }.merge!(common_user_params))

used_organization_names = []
total_organizations.times do |org_idx|
  puts "Creating organization #{org_idx + 1}/#{total_organizations}"

  name = Faker::Company.name
  name = Faker::Company.name while used_organization_names.include?(name)
  used_organization_names << name
  organization = Organization.create!(name: name)

  org_admins_per_organization.times do |org_admin_idx|
    params = { role: :org_admin,
               organization: organization,
               email: "#{org_idx}-#{org_admin_idx}-org-admin@example.org" }
    User.create!(params.merge!(common_user_params))
  end

  employees_per_organization.times do |employee_idx|
    params = { role: :employee,
               organization: organization,
               email: "#{org_idx}-#{employee_idx}-employee@example.org" }
    employee = User.create!(params.merge!(common_user_params))
    add_attendances_to(employee)
  end
end
