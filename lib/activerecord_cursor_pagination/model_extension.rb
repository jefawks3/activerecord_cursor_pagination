module ActiverecordCursorPagination
  module ModelExtension
    extend ActiveSupport::Concern

    class_methods do
      ##
      # Get the paginated cursor for the current query
      #
      # @param [String, Cursor, EmptyCursor, ActiveRecord::Base, nil] cursor
      #
      #   The current page cursor.
      #
      #   If an ActiveRecord::Base is passed, the current page will be calculated based on the record id.
      #
      # @option [Integer] per
      #
      #   Limit the number of records per page.
      #
      # @return [CursorScope] The current page scope
      def cursor(cursor, per: 15)
        klass = all.instance_variable_get :@klass
        CursorScope.new klass, self, cursor, per: per
      end

      ##
      # Page batching using a cursor
      #
      # @option [Integer] batch_size
      #
      #   Limits the size of each batch
      #
      # @yield [cursor_scope] Invokes the block with the cursor_scope for each result.
      def cursor_batch(batch_size: 1000, &block)
        current_cursor = nil

        begin
          cursor = cursor current_cursor, per: batch_size
          block.call cursor
          current_cursor = cursor.next_cursor
        end until cursor.last_page?
      end

      ##
      # Page batching using a cursor
      #
      # @option [Integer] batch_size
      #
      #   Limits the size of each batch
      #
      # @yield [cursor_scope] Invokes the block with the cursor scope and the index for each result.
      def cursor_batch_with_index(batch_size: 1000, &block)
        i = 0

        self.cursor_batch batch_size: batch_size do |c|
          block.call c, i
          i += 1
        end
      end

      ##
      # Find each record using the cursor batch
      #
      # @option [Integer] batch_size
      #
      #   Limits the size of each batch
      #
      # @yield [record] Invokes the block with a record for each result.
      def cursor_find_each(batch_size: 1000, &block)
        self.cursor_batch batch_size: batch_size do |c|
          c.each &block
        end
      end

      ##
      # Find each record using the cursor batch
      #
      # @option [Integer] batch_size
      #
      #   Limits the size of each batch
      #
      # @yield [record] Invokes the block with a record and the index for each result.
      def cursor_find_each_with_index(batch_size: 1000, &block)
        i = 0

        self.cursor_batch batch_size: batch_size do |c|
          c.each do |r|
            block.call r, i
            i += 1
          end
        end
      end
    end
  end
end