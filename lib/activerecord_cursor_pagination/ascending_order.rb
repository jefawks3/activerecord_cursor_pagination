module ActiverecordCursorPagination
  class AscendingOrder < OrderBase
    def direction
      :asc
    end

    def reverse
      order = DescendingOrder.new table, name, index
      order.base_id = base_id
      order
    end

    def than_op
      '>'
    end

    def than_or_equal_op
      '>='
    end
  end
end