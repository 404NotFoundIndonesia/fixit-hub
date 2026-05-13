# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

FixIT Hub — web app for managing HP/laptop service and repair operations. Three roles: Admin, Technician, Customer. Rails 7 + Hotwire stack.

## Commands

```bash
# Install dependencies
bundle install

# Database (first time or after credential changes)
rails db:setup        # create + migrate + seed
rails db:migrate      # run pending migrations
rails db:seed         # seed only

# Run server
rails server          # http://localhost:3000

# Tests
rails test                        # all tests
rails test test/models/foo_test.rb  # single file
rails test test/models/foo_test.rb:42  # single test by line

# Credentials (PostgreSQL creds stored here)
rails credentials:edit
```

## Credentials

PostgreSQL credentials live in `config/credentials.yml.enc` (encrypted). Required keys:

```yaml
postgre_username: ...
postgre_password: ...
postgre_hostname: ...
postgre_database: ...
```

Edit with `rails credentials:edit`. Needs `config/master.key`.

## Stack

- **Ruby** 3.0.2 / **Rails** 7.0.8
- **Database**: PostgreSQL (dev + prod), SQLite (test)
- **Frontend**: Hotwire (Turbo + Stimulus) via importmap — no Node/webpack
- **Auth**: Devise (planned — not yet added to Gemfile)
- **Real-time**: Redis + Action Cable
- **Tests**: Minitest (default Rails) + Capybara/Selenium for system tests

## Architecture Notes

Routes in `config/routes.rb` are currently empty — app is early-stage scaffolding. All domain logic (models, controllers, views) is yet to be built.

Test env uses SQLite (`db/test.sqlite3`) while dev/prod use PostgreSQL — schema must stay compatible with both adapters.

Importmap means JS dependencies are pinned in `config/importmap.rb` via CDN or `vendor/javascript/`, not npm.
