# frozen_string_literal: true

require "active_record"
require "openssl"
require "digest"
require "json"

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

module ActiverecordCursorPagination # :nodoc:
  ##
  # Generic namespace error
  class Error < StandardError; end

  ##
  # Raised when no secret key can be found or is configured.
  class NoSecretKeyError < Error; end

  ##
  # Raised when trying to use the page view helper when the +per+ option is greater than one.
  class NotSingleRecordError < Error; end

  ##
  # Generic cursor error
  class CursorError < Error
    attr_reader :cursor

    def initialize(msg = "Cursor error", cursor = nil)
      super(msg)
      @cursor = cursor
    end
  end

  ##
  # Raised when a cursor is invalid
  class InvalidCursorError < CursorError; end

  class << self
    ##
    # Get the current configuration for the plugin.
    def configuration
      @configuration ||= Configuration.new
    end

    ##
    # Setup the activerecord cursor pagination configuration.
    def setup(&block)
      block&.call configuration
    end

    ##
    # Helper method to quote a table name with a column.
    def quote_table_column(table, name)
      table.nil? || table.empty? ? quote_column(name) : "#{quote_table table}.#{quote_column name}"
    end

    ##
    # Helper method to quote a table name.
    def quote_table(table)
      table_exists?(table) ? connection.quote_table_name(table) : table
    end

    ##
    # Helper method to quote a column name.
    def quote_column(name)
      valid_name?(name) ? connection.quote_column_name(name) : name
    end

    ##
    # Helper method to strip out double quotes
    def strip_quotes(name)
      name&.gsub '"', ""
    end

    ##
    # Helper method to validate if the table or column name is a valid format.
    def valid_name?(name)
      /\A[\w_]+\z/.match? name
    end

    ##
    # Helper method to see if a table exists.
    def table_exists?(table)
      valid_name?(table) && connection.table_exists?(table)
    end

    ##
    # Helper method to get the current database connection.
    def connection
      ActiveRecord::Base.connection
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.include ActiverecordCursorPagination::Extension
end
