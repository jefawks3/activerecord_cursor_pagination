module ActiverecordCursorPagination
  class DescendingOrder < OrderBase
    def direction
      :desc
    end

    def reverse
      order = AscendingOrder.new table, name, index
      order.base_id = base_id
      order
    end

    def than_op
      '<'
    end

    def than_or_equal_op
      '<='
    end
  end
end