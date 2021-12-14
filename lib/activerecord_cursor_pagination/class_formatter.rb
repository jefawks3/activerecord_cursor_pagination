module ActiverecordCursorPagination
  class ClassFormatter
    ##
    # Format the class name
    #
    # @param [String, Symbol, Class] klass_or_name
    #
    # @return [String, nil] The formatted class name
    def format(klass_or_name)
      if klass_or_name.nil? || klass_or_name.is_a?(String)
        klass_or_name
      elsif klass_or_name.is_a? Symbol
        klass_or_name.to_s.camelcase
      else
        klass_or_name.name
      end
    end
  end
end