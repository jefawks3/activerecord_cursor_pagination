require 'active_record'
require 'openssl'
require 'digest'
require 'json'

require_relative "activerecord_cursor_pagination/version"
require_relative "activerecord_cursor_pagination/secret_key_finder"
require_relative "activerecord_cursor_pagination/configuration"
require_relative "activerecord_cursor_pagination/serializer"
require_relative "activerecord_cursor_pagination/secure_cursor_serializer"
require_relative "activerecord_cursor_pagination/class_formatter"
require_relative "activerecord_cursor_pagination/sql_signer"
require_relative "activerecord_cursor_pagination/empty_cursor"
require_relative "activerecord_cursor_pagination/cursor"
require_relative "activerecord_cursor_pagination/order_base"
require_relative "activerecord_cursor_pagination/ascending_order"
require_relative "activerecord_cursor_pagination/descending_order"
require_relative "activerecord_cursor_pagination/cursor_scope"
require_relative "activerecord_cursor_pagination/model_extension"
require_relative "activerecord_cursor_pagination/extension"

module ActiverecordCursorPagination
  class Error < StandardError; end
  class NoSecretKeyError < Error; end
  class NotSingleRecordError < Error; end

  class CursorError < Error
    attr_reader :cursor

    def initialize(msg='Cursor error',cursor=nil)
      super(msg)
      @cursor = cursor
    end
  end

  class InvalidCursorError < CursorError; end

  class << self
    attr_reader :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def setup(&block)
      block.call configuration if block
    end

    def quote_table_column(table, name)
      table.nil? || table.empty? ? quote_column(name) : "#{quote_table table}.#{quote_column name}"
    end

    def quote_table(table)
      table_exists?(table) ? connection.quote_table_name(table) : table
    end

    def quote_column(name)
      valid_name?(name) ? connection.quote_column_name(name) : name
    end

    def strip_quotes(name)
      name&.gsub '"', ''
    end

    def valid_name?(name)
      /\A[\w_]+\z/.match? name
    end

    def table_exists?(table)
      valid_name?(table) && connection.table_exists?(table)
    end

    def connection
      ActiveRecord::Base.connection
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send :include, ActiverecordCursorPagination::Extension
end
