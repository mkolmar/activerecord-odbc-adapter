module ODBCAdapter
  # Caches SQLGetInfo output
  class DatabaseMetadata
    FIELDS = %i[
      SQL_DBMS_NAME
      SQL_DBMS_VER
      SQL_IDENTIFIER_CASE
      SQL_QUOTED_IDENTIFIER_CASE
      SQL_IDENTIFIER_QUOTE_CHAR
      SQL_MAX_IDENTIFIER_LEN
      SQL_MAX_TABLE_NAME_LEN
      SQL_USER_NAME
      SQL_DATABASE_NAME
    ].freeze

    attr_reader :values

    # has_encoding_bug refers to https://github.com/larskanis/ruby-odbc/issues/2 where ruby-odbc in UTF8 mode
    # returns incorrectly encoded responses to getInfo
    def initialize(connection, has_encoding_bug = false)
      @values = Hash[
        FIELDS.map do |field|
          info = connection.get_info(ODBC.const_get(field))
          info = info.encode(Encoding.default_external, 'UTF-16LE') if info.is_a?(String) && has_encoding_bug
          [field, info]
        end
      ]
    end

    def adapter_class
      ODBCAdapter.adapter_for(dbms_name)
    end

    def upcase_identifiers?
      @upcase_identifiers ||= (identifier_case == ODBC::SQL_IC_UPPER)
    end

    # Create accessors for fields reported by the DBMS.
    FIELDS.each do |field|
      define_method(field.to_s.downcase.gsub('sql_', '')) do
        value_for(field)
      end
    end

    private

    def value_for(field)
      values[field]
    end
  end
end
