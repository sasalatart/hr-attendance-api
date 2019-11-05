# frozen_string_literal: true

default_password = 'napoleon'
total_organizations = 35
org_admins_per_organization = 5
employees_per_organization = 35

used_names = []

User.create!(role: :admin,
             email: 'admin@example.org',
             password: default_password)

total_organizations.times do |org_idx|
  puts "Creating organization #{org_idx + 1}/#{total_organizations}"

  name = Faker::Company.name
  name = Faker::Company.name while used_names.include?(name)
  used_names << name

  organization = Organization.create!(name: name)

  org_admins_per_organization.times do |org_admin_idx|
    User.create!(role: :org_admin,
                 organization: organization,
                 email: "#{org_idx}-#{org_admin_idx}-admin@example.org",
                 password: default_password)
  end

  employees_per_organization.times do |employee_idx|
    User.create!(role: :employee,
                 organization: organization,
                 email: "#{org_idx}-#{employee_idx}-employee@example.org",
                 password: default_password)
  end
end
