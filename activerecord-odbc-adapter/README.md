# ODBCAdapter

An ActiveRecord ODBC adapter that works with Rails 7. Primarily, this version adds an adapter for Snowflake that provides reasonable mapping of data types from Snowflake. Migrations for Snowflake are not supported.

This adapter will work for basic queries for most DBMSs out of the box, using the null adapter, without support for migrations. Column data types may not map as expected. Full support is provided for MySQL 5 and PostgreSQL 9 databases. MySQL and PostgreSQL adapters are not well-tested for this update.

Earlier version from Localytics works with Rails 5. Several forks provide a minimal fix for a breaking change in Rails 6.

Previous work had been done to make the adapter compatible with Rails 3.2 and 4.2. For those versions, use the 3.2.x or 4.2.x gem releases. A lot of this work is based on [OpenLink's ActiveRecord adapter](http://odbc-rails.rubyforge.org/) which works for earlier versions of Rails.

You can register your own adapter to get more support for your DBMS using the `ODBCAdapter.register` function.

## Installation

Ensure you have the ODBC driver installed on your machine. You will also need the driver for whichever database to which you want ODBC to connect.

Add this line to your application's Gemfile:

```ruby
gem 'odbc_adapter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install odbc_adapter

## Usage

Configure your `database.yml` by either using the `dsn` option to point to a DSN that corresponds to a valid entry in your `~/.odbc.ini` file:

```
development:
  adapter:  odbc
  dsn: MyDatabaseDSN
```

or by using the `conn_str` option and specifying the entire connection string:

```
development:
  adapter: odbc
  conn_str: "DRIVER={PostgreSQL ANSI};SERVER=localhost;PORT=5432;DATABASE=my_database;UID=postgres;"
```

ActiveRecord models that use this connection will now be connecting to the configured database using the ODBC driver.

## Testing

To run the tests, you'll need the ODBC driver as well as the connection adapter for each database against which you're trying to test. Then run `DSN=MyDatabaseDSN bundle exec rake test` and the test suite will be run by connecting to your database.

## Testing Using a Docker Container Because ODBC on Mac is Hard

Tested on Sierra.


Run from project root:

```
bundle package
docker build -f Dockerfile.dev -t odbc-dev .

# Local mount mysql directory to avoid some permissions problems
mkdir -p /tmp/mysql
docker run -it --rm -v $(pwd):/workspace -v /tmp/mysql:/var/lib/mysql odbc-dev:latest

# In container
docker/test.sh
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mkolmar/odbc_adapter.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
