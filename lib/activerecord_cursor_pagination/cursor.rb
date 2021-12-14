module ActiverecordCursorPagination
  class Cursor
    attr_reader :klass_name, :signed_sql, :per_page, :start_id, :end_id

    ##
    # Initialize a cursor
    #
    # @param [Class, String] klass_or_name The model class
    # @param [ActiveRecord::Relation, String] sql_or_signed_sql The active record SQL relation
    # @param [Integer] per_page The number of records per page
    # @param [Integer] start_id The ID of the first record in the page
    # @param [Integer] end_id The ID of the last record in the page
    def initialize(klass_or_name, sql_or_signed_sql, per_page, start_id, end_id)
      @signed_sql = sql_or_signed_sql.is_a?(String) ? sql_or_signed_sql : sql_signer.sign(sql_or_signed_sql)
      @klass_name = class_formatter.format klass_or_name
      @per_page = per_page
      @start_id = start_id
      @end_id = end_id
    end

    ##
    # Is the cursor not empty
    #
    # @return [Boolean]
    def present?
      !empty?
    end

    ##
    # Is the cursor empty
    #
    # @return [Boolean]
    def empty?
      @start_id.nil? || @end_id.nil?
    end

    ##
    # Gets the hash representation of the cursor
    #
    # @return [Hash]
    def to_hash
      {
        start: @start_id,
        end: @end_id,
        per_page: @per_page,
        model: @klass_name,
        sql: @signed_sql
      }
    end

    ##
    # Get the string representation of the cursor
    #
    # @return [String] The serialized cursor
    def to_s
      serializer.serialize to_hash
    end

    alias_method :to_param, :to_s

    ##
    # Validates the cursor
    #
    # @param [Class] klass The model class
    # @param [ActiveRecord::Relation] sql The active record SQL relation
    # @param [Integer] per_page The number of records per page
    #
    # @raise [InvalidCursorError] If cursor is not valid
    def validate!(klass, sql, per_page)
      raise InvalidCursorError.new('Invalid cursor', self) unless valid?(klass, sql, per_page)
    end

    private

    delegate :class_formatter, :sql_signer, :serializer, to: :class

    def valid?(klass, sql, per_page)
      formatted_class = class_formatter.format klass
      signed_sql = sql.is_a?(String) ? sql : sql_signer.sign(sql)

      @klass_name === formatted_class &&
        @signed_sql === signed_sql &&
        @per_page === per_page
    end

    class << self
      ##
      # Get sql signer instance
      #
      # @return [SqlSigner]
      def sql_signer
        SqlSigner.new
      end

      ##
      # Get class formatter
      #
      # @return [ClassFormatter]
      def class_formatter
        ClassFormatter.new
      end

      ##
      # Get cursor serializer instance
      #
      # @return [Serializer]
      def serializer
        ActiverecordCursorPagination.configuration.serializer_instance
      end

      ##
      # Parse the cursor string
      #
      # @param [String] str Cursor serialized string.
      #
      # @return [Cursor, EmptyCursor] Instance of Cursor.
      def parse(str)
        return EmptyCursor.new if str.nil? || str.empty?

        hash = serializer.deserialize str

        new hash[:model],
            hash[:sql],
            hash[:per_page],
            hash[:start],
            hash[:end]
      end

      ##
      # Serialize the cursor
      #
      # @param [Class, String] klass_or_name The model class
      # @param [ActiveRecord::Relation, String] sql_or_signed_sql The active record SQL relation
      # @param [Integer] per_page The number of records per page
      # @param [Integer] start_id The ID of the first record in the page
      # @param [Integer] end_id The ID of the last record in the page
      #
      # @return [String] The serialized cursor string
      def to_param(klass_or_name, sql_or_signed_sql, per_page, start_id, end_id)
        new(klass_or_name, sql_or_signed_sql, per_page, start_id, end_id).to_param
      end
    end
  end
end