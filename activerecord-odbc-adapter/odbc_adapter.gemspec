# -*- encoding: utf-8 -*-
# stub: odbc_adapter 7.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "odbc_adapter".freeze
  s.version = "7.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Medical College of Wisconsin".freeze, "Localytics".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-08-08"
  s.email = ["mkolmar@mcw.edu".freeze, "oss@localytics.com".freeze]
  s.files = [".gitignore".freeze, ".rubocop.yml".freeze, ".travis.yml".freeze, "Dockerfile.dev".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "bin/ci-setup".freeze, "bin/console".freeze, "bin/setup".freeze, "docker/docker-entrypoint.sh".freeze, "docker/test.sh".freeze, "lib/active_record/connection_adapters/odbc_adapter.rb".freeze, "lib/odbc_adapter.rb".freeze, "lib/odbc_adapter/adapters/mysql_odbc_adapter.rb".freeze, "lib/odbc_adapter/adapters/null_odbc_adapter.rb".freeze, "lib/odbc_adapter/adapters/postgresql_odbc_adapter.rb".freeze, "lib/odbc_adapter/adapters/snowflake_odbc_adapter.rb".freeze, "lib/odbc_adapter/column.rb".freeze, "lib/odbc_adapter/column_metadata.rb".freeze, "lib/odbc_adapter/database_limits.rb".freeze, "lib/odbc_adapter/database_metadata.rb".freeze, "lib/odbc_adapter/database_statements.rb".freeze, "lib/odbc_adapter/error.rb".freeze, "lib/odbc_adapter/quoting.rb".freeze, "lib/odbc_adapter/registry.rb".freeze, "lib/odbc_adapter/schema_statements.rb".freeze, "lib/odbc_adapter/version.rb".freeze, "odbc_adapter.gemspec".freeze]
  s.homepage = "https://github.com/mkolmar/odbc_adapter".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.22".freeze
  s.summary = "An ActiveRecord ODBC adapter that works with Snowflake".freeze

  s.installed_by_version = "3.2.22" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<ruby-odbc>.freeze, ["~> 0.9"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 2.4"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.10"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_development_dependency(%q<rubocop>.freeze, ["= 0.48.1"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.14"])
  else
    s.add_dependency(%q<ruby-odbc>.freeze, ["~> 0.9"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.14"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.10"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_dependency(%q<rubocop>.freeze, ["= 0.48.1"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.14"])
  end
end
