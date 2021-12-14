module ActiverecordCursorPagination
  class CursorScope
    attr_reader :per_page

    ##
    # @example Empty cursor
    #   Posts.where(published: true).order(created_at: :desc).cursor(nil, per: 100)
    #   Posts.where(published: true).order(created_at: :desc).cursor("", per: 100)
    #   Posts.where(published: true).order(created_at: :desc).cursor(EmptyCursor.new, per: 100)
    #
    # @example Serialized cursor
    #   Posts.where(published: true).order(created_at: :desc).cursor("SerializedCursorString", per: 100)
    #
    # @example Record cursor
    #   Posts.where(published: true).order(created_at: :desc).cursor(Post.find!(6), per: 100)
    #
    # @example Cursor
    #   cursor = ...deserialized cursor...
    #   Posts.where(published: true).order(created_at: :desc).cursor(cursor, per: 100)
    #
    # @param [Class] klass Model class
    # @param [ActiveRecord::Relation] scope The database query.
    # @param [String, Cursor, EmptyCursor, ActiveRecord::Base, nil] cursor The current page cursor.
    # @option [Integer] per The number of records per page.
    #
    # @raise [InvalidCursorError] When the cursor is does not match the query or the cursor is not a valid type.
    def initialize(klass, scope, cursor, per: 15)
      @scope = scope.except :offset, :limit
      @klass = klass
      @per_page = per
      @table = @scope.table_name
      @id_column = "#{@table}.id"

      initialize_order_columns
      initialize_cursor cursor
      initialize_order_column_values
    end

    ##
    # Get if the query is for single records
    #
    # @return [Boolean] True if only one record per page
    def single_record?
      @per_page === 1
    end

    ##
    # Get the total count of records from the query scope.
    #
    # @return [Integer] The number of total records.
    def scope_size
      @scope.except(:select).size
    end

    alias_method :scope_count, :scope_size
    alias_method :total_count, :scope_size
    alias_method :total, :scope_size

    ##
    # Get if there are not records from the query scope.
    #
    # @return [Boolean] True if the query scope is empty.
    def scope_empty?
      total_count.zero?
    end

    alias_method :scope_none?, :scope_empty?

    ##
    # Get if there are records from the query scope.
    #
    # @return [Boolean] True if the query scope is not empty.
    def scope_any?
      !scope_empty?
    end

    ##
    # Get if there is only one record from the query scope.
    #
    # @return [Boolean] True if there is only one record.
    def scope_one?
      total_count == 1
    end

    ##
    # Get if there are many records from the query scope.
    #
    # @return [Boolean] True if there is more than one record.
    def scope_many?
      total_count > 1
    end

    ##
    # Get the number of records in the current page
    #
    # @return [Integer] The number of records
    def size
      current_page_scope.except(:select).size
    end

    alias_method :count, :size
    alias_method :length, :size

    ##
    # Get if there no records in the current page.
    #
    # @return [Boolean] True if there are no records.
    def empty?
      size.zero?
    end

    alias_method :none?, :empty?

    ##
    # Get if there are records in the current page.
    #
    # @return [Boolean] True if not empty.
    def any?
      !empty?
    end

    ##
    # Get if there are many records in the current page.
    #
    # @return [Boolean] True if there is more than one record.
    def many?
      size > 1
    end

    ##
    # Get if there is only one in the current page.
    #
    # @return [Boolean] True if there is only one record.
    def one?
      size == 1
    end

    ##
    # Get if there is a previous page from the cursor
    #
    # @return [Boolean] True if there is previous page
    def previous_page?
      return false if scope_empty?
      previous_page_scope.any?
    end

    ##
    # Get if there is another page
    #
    # @return [Boolean] True if there is a next page
    def next_page?
      return false if scope_empty?
      next_page_scope.any?
    end

    ##
    # Get if the cursor is the first page
    #
    # @return [Boolean] True if first page
    def first_page?
      scope_empty? || !previous_page?
    end

    ##
    # Get if the cursor is the last page
    #
    # @return [Boolean] True if last page
    def last_page?
      scope_empty? || !next_page?
    end

    ##
    # Get the current cursor
    #
    # @return [String] The current cursor
    def current_cursor
      @cursor.to_param
    end

    ##
    # Get the next page cursor
    #
    # @return [String]
    def next_cursor
      return EmptyCursor.to_param unless next_page?
      ids = next_page_scope.pluck(:id)
      Cursor.to_param @klass, @scope, @per_page, ids.first, ids.last
    end

    ##
    # Get the next record
    #
    # @raise [NotSingleRecordError] If the number of records per page is not one.
    #
    # @return [ActiveRecord::Base]
    def next_cursor_record
      raise NotSingleRecordError unless single_record?
      next_page_scope.first if next_page?
    end

    ##
    # Get the previous page cursor.
    #
    # @return [String]
    def previous_cursor
      return EmptyCursor.to_param unless previous_page?
      ids = previous_page_scope.pluck(:id)
      Cursor.to_param @klass, @scope, @per_page, ids.last, ids.first
    end

    ##
    # Get the previous record.
    #
    # @raise [NotSingleRecordError] If the number of records per page is not one.
    #
    # @return [ActiveRecord::Base]
    def previous_cursor_record
      raise NotSingleRecordError unless single_record?
      previous_page_scope.first if previous_page?
    end

    ##
    # Iterate each record in the current page.
    #
    # @yield [ActiveRecord::Base] Invokes the block with each active record.
    def each(&block)
      current_page_scope.each &block
    end

    ##
    # Iterate each record in the current page.
    #
    # @yield [ActiveRecord::Base, Integer] Invokes the block with each active record and page row index.
    def each_with_index(&block)
      i = 0
      current_page_scope.each do |r|
        block.call r, i
        i += 1
      end
    end

    ##
    # Map each record in the current page.
    #
    # @yield [ActiveRecord::Base] Invokes the block with each active record.
    def map(&block)
      current_page_scope.map &block
    end

    ##
    # Map each record in the current page.
    #
    # @yield [ActiveRecord::Base, Integer] Invokes the block with each active record and page row index.
    def map_with_index(&block)
      current_page_scope.map.with_index do |r, i|
        block.call r, i
      end
    end

    private

    def initialize_order_columns
      # FIXME Limitation / Code Smell - Invoking Private Method
      #   As of right now, there is no public method to get the values from the .order() method.
      #   The private .order_values method is undocumented and future releases of ActiveRecord can
      #     remove/change this method.
      #   See .order! for reference to the method.
      #   https://apidock.com/rails/v5.1.7/ActiveRecord/QueryMethods/order%21
      @order_columns = @scope.send(:order_values).map.with_index do |node, index|
        order = OrderBase.parse node, index
        order.base_id = order.table === @table && order.name == 'id'
        order
      end

      unless @order_columns.any?(&:base_id?)
        order_column = AscendingOrder.new @table, 'id', @order_columns.size
        order_column.base_id = true
        @order_columns << order_column
        @scope = @scope.order order_column.order_sql
      end

      @id_column_index = @order_columns.find_index &:base_id?
    end

    def initialize_cursor(cursor)
      @cursor = EmptyCursor.new

      if cursor.nil? || cursor.try(:empty?)
        ids = build_sql_order(@scope, false).limit(@per_page).pluck(:id)

        @cursor = Cursor.new @klass, @scope, @per_page, ids.first, ids.last unless ids.empty?
      elsif cursor.is_a? Cursor
        @cursor = cursor
      elsif cursor.is_a? String
        @cursor = Cursor.parse cursor
      elsif cursor.is_a? ActiveRecord::Base
        if single_record?
          @cursor = Cursor.new @klass, @scope, @per_page, cursor.id, cursor.id
        else
          calculate_cursor_from_record cursor
        end
      else
        raise InvalidCursorError.new("Invalid cursor type #{cursor.class.name}", cursor)
      end

      @cursor.validate! @klass, @scope, @per_page unless @cursor.empty?
    end

    def initialize_order_column_values
      if @cursor.empty?
        @start_column_values = @end_column_values = []
      elsif single_record?
        @start_column_values = @end_column_values = ensure_array @scope.only(:from, :joins)
                                                                       .where(id: @cursor.start_id).limit(1)
                                                                       .pluck(*@order_columns.map(&:quote_full_name))
                                                                       .first
      else
        query = @scope.only :from, :joins

        @start_column_values = ensure_array query.where(id: @cursor.start_id)
                                                 .limit(1)
                                                 .pluck(*@order_columns.map(&:quote_full_name))
                                                 .first

        @end_column_values = ensure_array query.where(id: @cursor.end_id)
                                               .limit(1)
                                               .pluck(*@order_columns.map(&:quote_full_name))
                                               .first
      end
    end

    def build_sql_order(query, reverse)
      order_array = @order_columns.map { |c| reverse ? c.reverse.order_sql : c.order_sql }
      query.unscope(:order).order(*order_array)
    end

    def build_sql_from_columns(query, column_values, id_direction: :start)
      conditions = []

      values_hash = 0.upto(column_values.size - 1).inject({}) do |hash, i|
        hash.merge @order_columns[i].statement_key => column_values[i]
      end

      @order_columns.each_with_index do |column, i|
        sql = []

        0.upto(i - 1) { |p| sql << @order_columns[p].equals_sql }

        if column.base_id?
          if id_direction == :previous
            sql << column.reverse.than_sql
          elsif id_direction == :next
            sql << column.than_sql
          elsif id_direction == :end
            sql << column.reverse.than_or_equal_sql
          else
            sql << column.than_or_equal_sql
          end
        else
          if id_direction == :previous || id_direction == :end
            sql << column.reverse.than_sql
          else
            sql << column.than_sql
          end
        end

        conditions << "(#{sql.join ' AND '})"
      end

      query.where conditions.join(' OR '), values_hash
    end

    def calculate_cursor_from_record(record)
      column_values = @scope.only(:from, :joins)
                            .where(id: record.id)
                            .limit(1)
                            .pluck(*@order_columns.map(&:full_name))
                            .first

      column_values = ensure_array column_values
      query = build_sql_order @scope.only(:from, :joins, :where), false
      count_query = build_sql_from_columns query, column_values, id_direction: :previous
      count_query = build_sql_order count_query, true
      page = (count_query.count / @per_page).floor

      page_values = query.offset(page * @per_page)
                         .limit(@per_page)
                         .pluck(*@order_columns.map(&:full_name))

      @start_column_values = ensure_array page_values.first
      @end_column_values = ensure_array page_values.last

      @cursor = Cursor.new @klass,
                           @scope,
                           @per_page,
                           @start_column_values[@id_column_index],
                           @end_column_values[@id_column_index]
    end

    def previous_page_scope
      query = build_sql_from_columns @scope, @start_column_values, id_direction: :previous
      query = build_sql_order query, true
      query.limit @per_page
    end

    def current_page_scope
      if @cursor.empty?
        build_sql_order(@scope, false).limit(@per_page)
      else
        query = build_sql_from_columns @scope, @start_column_values, id_direction: :start
        query = build_sql_from_columns query, @end_column_values, id_direction: :end
        build_sql_order query, false
      end
    end

    def next_page_scope
      query = build_sql_from_columns @scope, @end_column_values, id_direction: :next
      query = build_sql_order query, false
      query.limit @per_page
    end

    def ensure_array(value)
      value.is_a?(Array) ? value : [value]
    end
  end
end