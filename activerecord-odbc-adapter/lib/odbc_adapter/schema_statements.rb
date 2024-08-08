require 'odbc'

module ODBCAdapter
  module SchemaStatements
    # Returns a Hash of mappings from abstract data types to native data types,
    # if available.
    def native_database_types
      @native_database_types ||= ColumnMetadata.new(self).native_database_types
    end

    # Returns an array of table names, for database tables visible on the
    # current connection.
    def tables(_name = nil)
      stmt = @connection.tables
      result = stmt&.fetch_all || []
      stmt&.drop

      result.each_with_object([]) do |row, table_names|
        schema_name, table_name, table_type = row[1..3]
        next if respond_to?(:table_filtered?) && table_filtered?(schema_name, table_type)

        table_names << format_case(table_name)
      end
    end

    # TODO: Implement.
    # Returns an array of view names defined in the database.
    def views
      []
    end

    # Returns an array of indexes for the given table.
    def indexes(table_name, _name = nil)
      stmt = @connection.indexes(native_case(table_name.to_s))
      result = stmt&.fetch_all || []
      stmt&.drop

      index_cols = []
      index_name = nil
      unique = nil

      result.each_with_object([]).with_index do |(row, indices), row_idx|
        # Skip table statistics
        next if row[6].zero? # SQLStatistics: TYPE

        if row[7] == 1 # SQLStatistics: ORDINAL_POSITION
          # Start of column descriptor block for next index
          index_cols = []
          unique = row[3].zero? # SQLStatistics: NON_UNIQUE
          index_name = String.new(row[5]) # SQLStatistics: INDEX_NAME
        end

        index_cols << format_case(row[8]) # SQLStatistics: COLUMN_NAME
        next_row = result[row_idx + 1]

        if (row_idx == result.length - 1) || (next_row[6].zero? || next_row[7] == 1)
          indices << ActiveRecord::ConnectionAdapters::IndexDefinition.new(
            table_name, format_case(index_name), unique, index_cols
          )
        end
      end
    end

    def generic_type(type)
      ColumnMetadata::GENERICS.fetch(type) { [] }
    end

    def generic_type_include?(type, col_data_type)
      generic_type(type).include?(col_data_type)
    end

    # Returns an array of Column objects for the table specified by
    # +table_name+.
    def columns(table_name, _name = nil)
      stmt = @connection.columns(native_case(table_name.to_s))
      result = stmt&.fetch_all || []
      stmt&.drop

      result.each_with_object([]) do |col, cols|
        col_name = col[3] # SQLColumns: COLUMN_NAME
        col_data_type = col[4] # SQLColumns: DATA_TYPE
        col_type_name = col[5] # SQLColumns: TYPE_NAME
        col_limit = col[6] # SQLColumns: COLUMN_SIZE
        col_scale = col[8] # SQLColumns: DECIMAL_DIGITS
        col_default = col[12] # SQLColumns: COLUMN_DEF

        # SQLColumns: IS_NULLABLE, SQLColumns: NULLABLE
        col_nullable = nullability(col_name, col[17], col[10])

        meta = { sql_type: col_type_name, type: col_data_type, limit: col_limit }
        meta[:sql_type] = 'BOOLEAN' if col_type_name == self.class::BOOLEAN_TYPE

        # These types are not expected when an ODBC driver is used. Values will
        # be cast to String instead.
        if [self.class::VARIANT_TYPE, self.class::JSON_TYPE, self.class::STRUCT_TYPE].include?(col_type_name)
          meta[:sql_type] = 'json'
        end

        # Precision, scale, limit are not part of type name from Snowflake ODBC.
        # Type map expects to extract precision, scale, limit from sql_type.
        if col_type_name.index('(').nil?

          # Character or string types with precision
          if %w[VARCHAR].include?(col_type_name) || generic_type_include?(:text, col_data_type)
            meta[:precision] = col_limit
            meta[:sql_type] = "#{col_type_name}(#{meta[:precision]})"
          end

          # Numeric types with precision and scale. Assumes INT when scale is zero.
          if %w[DECIMAL NUMERIC].include?(col_type_name) || generic_type_include?(:decimal, col_data_type)
            meta[:scale] = col_scale || 0
            meta[:precision] = col_limit
            meta[:sql_type] =
              if meta[:scale].zero?
                'INT'
              else
                "#{col_type_name}(#{meta[:precision]},#{meta[:scale]})"
              end
          end
        end

        sql_type_metadata = ActiveRecord::ConnectionAdapters::SqlTypeMetadata.new(**meta)
        cols << new_column(
          format_case(col_name),
          col_default,
          sql_type_metadata,
          col_nullable,
          col_type_name,
          collation: nil,
          comment: nil
        )
      end
    end

    # Returns table's primary key
    def primary_key(table_name)
      stmt = @connection.primary_keys(native_case(table_name.to_s))
      result = stmt&.fetch_all || []
      stmt&.drop
      result[0] && result[0][3]
    end

    def foreign_keys(table_name)
      stmt = @connection.foreign_keys(native_case(table_name.to_s))
      result = stmt&.fetch_all || []
      stmt&.drop
      result.map do |key|
        fk_from_table = key[2] # PKTABLE_NAME
        fk_to_table = key[6] # FKTABLE_NAME
        ActiveRecord::ConnectionAdapters::ForeignKeyDefinition.new(
          fk_from_table,
          fk_to_table,
          name: key[11], # FK_NAME
          column: key[3], # PKCOLUMN_NAME
          primary_key: key[7], # FKCOLUMN_NAME
          on_delete: key[10], # DELETE_RULE
          on_update: key[9] # UPDATE_RULE
        )
      end
    end

    # Ensure it's shorter than the maximum identifier length for the current
    # dbms
    def index_name(table_name, options)
      maximum = database_metadata.max_identifier_len || 255
      super(table_name, options)[0...maximum]
    end

    def current_database
      database_metadata.database_name.strip
    end
  end
end
