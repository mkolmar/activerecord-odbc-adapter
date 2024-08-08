module ODBCAdapter
  module Adapters
    # Snowflake adapter allows for minimal support, assumes primarily read access
    # to data warehouse. Columns map to appropriate data types.
    #
    # PostgreSQLODBCAdapter and MySQLODBCAdapter have examples that might be
    # adaptable to support DDL or Rails migrations for Snowflake.
    class SnowflakeODBCAdapter < ActiveRecord::ConnectionAdapters::ODBCAdapter
      JSON_TYPE = 'JSON'.freeze
      STRUCT_TYPE = 'STRUCT'.freeze
      VARIANT_TYPE = 'VARIANT'.freeze
      ARRAY_TYPE = 'ARRAY'.freeze
      OBJECT_TYPE = 'OBJECT'.freeze

      # Build the type map for ActiveRecord
      class << self
        protected

        attr_accessor :type_map

        def initialize_type_map(map)
          register_class_with_limit(map, /boolean/i, ActiveRecord::Type::Boolean)
          register_class_with_limit(map, /\Achar/i, ActiveRecord::Type::String)
          register_class_with_limit(map, /\Avarchar/i, ActiveRecord::Type::String)
          register_class_with_limit(map, /binary/i, ActiveRecord::Type::Binary)
          register_class_with_limit(map, /text/i, ActiveRecord::Type::Text)
          register_class_with_precision(map, /\Adate/i, ActiveRecord::Type::Date)
          register_class_with_precision(map, /\Atime/i, ActiveRecord::Type::Time)
          register_class_with_precision(map, /\Adatetime/i, ActiveRecord::Type::DateTime)
          register_class_with_limit(map, /float/i, ActiveRecord::Type::Float)
          register_class_with_limit(map, /int/i, ActiveRecord::Type::Integer)

          map.alias_type(/blob/i, 'binary')
          map.alias_type(/clob/i, 'text')
          map.alias_type(/timestamp/i, 'datetime')
          map.alias_type(/numeric/i, 'decimal')
          map.alias_type(/number/i, 'decimal')
          map.alias_type(/double/i, 'float')

          # ActiveRecord actually gives String type for STRUCT, a limitation of
          # ODBC. Models may use serialize class method or attribute reader to
          # handle JSON.
          map.register_type(/json/i, ActiveRecord::Type::Json)
          map.register_type(/struct/i, ActiveRecord::Type::Json)

          # Assumes DB driver or earlier logic produces e.g. "DECIMAL(p,s)".
          # Snowflake ODBC does not have precision/scale in data type string.
          # ODBCAdapter::SchemaStatements interpolates data type to make
          # precision and scale available here.
          map.register_type(/decimal/i) do |sql_type|
            ActiveRecord::Type::Decimal.new(
              precision: extract_precision(sql_type),
              scale: extract_scale(sql_type)
            )
          end
        end

        def register_class_with_limit(mapping, key, klass)
          mapping.register_type(key) { |*args| klass.new(limit: extract_limit(args.last)) }
        end

        def register_class_with_precision(mapping, key, klass)
          mapping.register_type(key) { |*args| klass.new(precision: extract_precision(args.last)) }
        end

        def extract_scale(sql_type)
          case sql_type
          when /\((\d+)\)/ then 0
          when /\((\d+)(,(\d+))\)/ then $3.to_i
          end
        end

        def extract_precision(sql_type)
          $1.to_i if sql_type =~ /\((\d+)(,\d+)?\)/
        end

        def extract_limit(sql_type)
          $1.to_i if sql_type =~ /\((.*)\)/
        end

        # Can't use the built-in ActiveRecord map#alias_type because it doesn't
        # work with non-string keys, and in our case the keys are (almost) all
        # numeric
        def alias_type(map, new_type, old_type)
          map.register_type(new_type) { |_, *args| map.lookup(old_type, *args) }
        end
      end

      self.type_map = ActiveRecord::Type::TypeMap.new.tap { |m| initialize_type_map(m) }

      # Using a Visitor so that the SQL string is substituted before it is
      # sent to the DBMS (to attempt to get as much coverage as possible for
      # DBMSs we don't support).
      #
      # PostgreSQL may be close enough.
      def arel_visitor
        Arel::Visitors::PostgreSQL.new(self)
      end

      # Quotes a string, escaping any ' (single quote) and \ (backslash)
      # characters.
      def quote_string(string)
        string.gsub(/\\/, '\&\&').gsub(/'/, "''")
      end

      # TODO: Investigate how prepared statements might be used in Snowflake.
      # Explicitly turns off prepared_statements.
      def prepared_statements
        false
      end

      # Turns off support for migrations.
      def supports_migrations?
        false
      end
    end
  end
end
