module ActiverecordCursorPagination
  class OrderBase
    attr_reader :table, :name, :index, :direction

    attr_accessor :base_id

    ##
    # Initialize the OrderBase.
    #
    # @param [String] table The table name.
    # @param [String] name The name of the column.
    # @param [Integer] index The index of the order column.
    def initialize(table, name, index)
      @table = ActiverecordCursorPagination.strip_quotes table
      @name = ActiverecordCursorPagination.strip_quotes name
      @base_id = false
      @index = index
    end

    ##
    # Get the direction of the order.
    #
    # @abstract
    #
    # @return [Symbol] Returns the order symbol.
    def direction
      raise NotImplementedError
    end

    ##
    # Get if the order column is the base id of the table.
    #
    # @return [Boolean] Is the base id.
    def base_id?
      !!@base_id
    end

    ##
    # Get if the table name is defined.
    #
    # @return [Boolean] True if the table is defined.
    def table?
      !table.nil? && !table.empty?
    end

    ##
    # Get if the table exists.
    #
    # @return [Boolean] True if the table exists.
    def table_exists?
      ActiverecordCursorPagination.table_exists? table
    end

    ##
    # Get if the table name is a valid SQL database name.
    #
    # @return [Boolean] True if a valid name.
    def valid_table_name?
      ActiverecordCursorPagination.valid_name? table
    end

    ##
    # Get if the column name is a valid SQL column name.
    #
    # @return [Boolean] True if a valid name.
    def valid_name?
      ActiverecordCursorPagination.valid_name? name
    end

    ##
    # Get the statement key for the named SQL query.
    #
    # @return [Symbol] The statement key.
    def statement_key
      :"order_field#{index}"
    end

    ##
    # Get the full SQL name.
    #
    # @return [String].
    def full_name
      table? ? "#{table}.#{name}" : name
    end

    ##
    # Get the full quoted name.
    #
    # @return [String].
    def quote_full_name
      ActiverecordCursorPagination.quote_table_column table, name
    end

    ##
    # Get the quoted table name.
    #
    # @return [String, nil].
    def quote_table
      ActiverecordCursorPagination.quote_table table
    end

    ##
    # Get the quoted column name
    #
    # @return [String]
    def quote_name
      ActiverecordCursorPagination.quote_column name
    end

    ##
    # Get the reverse column order
    #
    # @abstract
    #
    # @return [OrderBase]
    def reverse
      raise NotImplementedError
    end

    ##
    # Get the SQL for the equals comparison
    #
    # @return [String]
    def equals_sql
      "#{quote_full_name} = :#{statement_key}"
    end

    ##
    # Get the SQL for the greater/less than comparison depending on direction
    #
    # @return [String]
    def than_sql
      "#{quote_full_name} #{than_op} :#{statement_key}"
    end

    ##
    # Get the SQL operation for the greater/less than comparison
    #
    # @abstract
    #
    # @return [String]
    def than_op
      raise NotImplementedError
    end

    ##
    # Get the SQL for the greater/less than or equal to comparison depending on direction
    #
    # @return [String]
    def than_or_equal_sql
      "#{quote_full_name} #{than_or_equal_op} :#{statement_key}"
    end

    ##
    # Get the SQL operation for the greater/less than or equal comparison
    #
    # @abstract
    #
    # @return [String]
    def than_or_equal_op
      raise NotImplementedError
    end

    ##
    # Get the SQL literal of the column order
    #
    # @return [Arel::Nodes::SqlLiteral] Sql literal
    def order_sql
      Arel.sql "#{quote_full_name} #{direction.to_s.upcase}"
    end

    class << self
      ##
      # Parse the order string or node
      #
      # @param [String, Arel::Nodes::Node, Arel::Nodes::SqlLiteral] string_or_sql_order_node
      #
      #   The table, column, and/or order representation.
      #
      # @param [Integer] index
      #
      #   The index of the node.
      #
      # @return [OrderBase]
      def parse(string_or_sql_order_node, index)
        if string_or_sql_order_node.is_a?(Arel::Nodes::SqlLiteral) || string_or_sql_order_node.is_a?(String)
          parse_string string_or_sql_order_node, index
        else
          parse_order_node string_or_sql_order_node, index
        end
      end

      ##
      # Parse the order string
      #
      # Limitations:
      #   1. Complex queries must use +'+ quotes for strings
      #
      # @param [String, Arel::Nodes::SqlLiteral] string_or_sql_literal
      #
      #   The string representation of the table, column, and/or order direction.
      #
      # @param [Integer] index
      #
      #   The index of the node.
      #
      # @return [OrderBase]
      def parse_string(string_or_sql_literal, index)
        string_or_sql_literal.strip!

        table_column, dir = if (match = string_or_sql_literal.match(/\A(?<rest>.*)\s+(?<order>ASC|DESC)\z/i))
                              [match[:rest]&.strip, match[:order]&.downcase]
                            else
                              [string_or_sql_literal, nil]
                            end

        order_klass = order_factory dir


        table, column = parse_table_column table_column.to_s.strip

        if column.nil? || column.empty?
          column = table
          table = nil
        end

        order_klass.new table, column, index
      end

      ##
      # Parse the order Arel node
      #
      # @param [Arel::Nodes::Node] node The order node.
      # @param [Integer] index The index of the order node.
      #
      # @return [OrderBase]
      def parse_order_node(node, index)
        order_klass = order_factory node.direction

        table, column = if node.expr.is_a? Arel::Nodes::SqlLiteral
                          parse_table_column node.expr.to_s.strip
                        else
                          [node.expr.relation.name, node.expr.name]
                        end

        if column.nil? || column.empty?
          column = table
          table = @table
        end

        order_klass.new table, column, index
      end

      ##
      # Order class factory
      #
      # @param [String, Symbol] direction The direction of the order column.
      def order_factory(direction)
        direction&.to_s&.downcase === 'desc' ? DescendingOrder : AscendingOrder
      end

      private

      def parse_table_column(str)
        # FIXME Double quoted strings vs column and table names
        #   Strings must be single quoted or the REGEXP will remove the double quotes creating invalid sql statement.
        if str =~ /\A["']?[\w_]+['"]?\.?['"]?[\w_]+['"]?\z/
          str.scan /[^".]+|"[^"]*"/
        else
          [nil, str]
        end
      end
    end
  end
end