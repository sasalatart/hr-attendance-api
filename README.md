# HR Attendances API

[![CircleCI](https://circleci.com/gh/sasalatart/hr-attendance-api.svg?style=svg&circle-token=480eba02084e289a583b796246008b97e305c676)](https://circleci.com/gh/sasalatart/hr-attendance-api)

## About

API built with Ruby on Rails for the Runa HR assignment.

Check out the
[OpenAPI Spec Documentation](https://app.swaggerhub.com/apis-docs/sasalatart/hr-attendance/1.0.0)
for more information about endpoints.

A React client may be found [in this repo](https://github.com/sasalatart/hr-attendance-client).

## Assumptions

- All users (except admins) belong to an organization, as the app was designed to work with multiple organizations/companies.
- There are three roles: `admins`, `org_admins`, and `employees`:

  - `admins`: May manage organizations, and manage org admins and employees within them.
  - `org_admins`: May create more org admins and employees for their organizations (and manage them),
    as well as read and manage employee attendances. These users do not check in nor check out (they
    do not have their own attendances).
  - `employees`: These may check in & check out their attendances, as well as see their own past
    attendances.

- Users have a timezone assigned to them, which may be updated. These timezones are also stored in
  each of their attendances as they are registered (checkin & checkout). This way attendances
  fetched have enough context to be read according to where each employee is geographically located,
  and thus their timestamps may be read correctly and not relative to where the user fetching the
  information is. This allows for multinational/remote organizations to use the application, where
  they span over different timezones, and read checkin & checkout times relative to where they were
  actually done.
- Authentication is done via short-lived JWTs (with a lifespan of 2 hours).

## Technologies and Services Used

- Ruby 2.6.3
- Rails 5.2
- PostgreSQL 12
- CircleCI
- Docker (API Deployment)
- Terraform (Infrastructure Deployment via AWS)

## Development Setup

1. Clone and cd into this repository.
2. Make sure to have [Ruby](https://rvm.io/) and [PostgreSQL](https://www.postgresql.org/) available
   on your machine.
3. Make sure you have access to the application's credentials, as explained in the next section.
4. Run `bundle install` to install ruby dependencies.
5. Setup the database by running `rails db:reset`.
6. Run `rails s` to run the application on port 3000.

## Credentials Setup

In order to sign the JWTs, as well as access a production database via password, you need to have
access to the encrypted credentials.

If you are going to use the ones in this project, just make sure that `RAILS_MASTER_KEY` env
variable is available, and has the corresponding value.

If you wish to edit them, just run:

```sh
$ EDITOR=vim rails credentials:edit
```

The secrets that will be needed are:

```yml
secret_key_base:

# only for production
db_password:
```

## Linter

You may run [rubocop](https://github.com/rubocop-hq/rubocop) by executing:

```sh
$ bundle exec rubocop
```

## Tests

You may run [rspec](https://rspec.info/) by executing:

```sh
$ bundle exec rspec
```
