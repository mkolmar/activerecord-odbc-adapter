module ODBCAdapter
  class Column < ActiveRecord::ConnectionAdapters::Column
    attr_reader :native_type

    # Add the native_type accessor to allow the native DBMS to report back what
    # it uses to represent the column internally.
    # rubocop:disable Metrics/ParameterLists
    def initialize(name, default, sql_type_metadata = nil, null = true, default_function = nil, native_type = nil, collation: nil, comment: nil, **)
      super(name, default, sql_type_metadata, null, default_function, collation: collation, comment: comment)
      @native_type = native_type
    end
  end
end
