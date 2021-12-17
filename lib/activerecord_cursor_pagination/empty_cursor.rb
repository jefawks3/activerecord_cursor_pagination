# frozen_string_literal: true

module ActiverecordCursorPagination
  ##
  # An empty cursor when no records are found or the cursor page is empty
  class EmptyCursor
    ##
    # Is the cursor not empty
    #
    # @return [Boolean]
    def present?
      false
    end

    ##
    # Is the cursor empty
    #
    # @return [Boolean]
    def empty?
      true
    end

    ##
    # Get the string representation of the cursor
    #
    # @return [String] The serialized cursor
    def to_s
      ""
    end

    alias_method :to_param, :to_s

    class << self
      def to_param
        EmptyCursor.new.to_param
      end
    end
  end
end
