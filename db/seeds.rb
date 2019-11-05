# frozen_string_literal: true

DEFAULT_PASSWORD = 'napoleon'
total_organizations = 35
org_admins_per_organization = 5
employees_per_organization = 35

def common_user_params
  {
    name: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    password: DEFAULT_PASSWORD
  }
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
    User.create!({ role: :org_admin,
                   organization: organization,
                   email: "#{org_idx}-#{org_admin_idx}-admin@example.org" }.merge!(common_user_params))
  end

  employees_per_organization.times do |employee_idx|
    User.create!({ role: :employee,
                   organization: organization,
                   email: "#{org_idx}-#{employee_idx}-employee@example.org" }.merge!(common_user_params))
  end
end
