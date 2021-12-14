RSpec.describe ActiverecordCursorPagination::AscendingOrder do
  subject do
    order = ActiverecordCursorPagination::AscendingOrder.new 'posts', 'created_at', 1
    order.base_id = true
    order
  end

  context '.direction' do
    it 'returns asc' do
      expect(subject.direction).to be :asc
    end
  end

  context '.reverse' do
    let(:reversed) { subject.reverse }

    it 'is a DescendingOrder' do
      expect(reversed).to be_a ActiverecordCursorPagination::DescendingOrder
    end

    it 'has same table name' do
      expect(reversed.table).to eq 'posts'
    end

    it 'has same column name' do
      expect(reversed.name).to eq 'created_at'
    end

    it 'has the same index' do
      expect(reversed.index).to eq 1
    end

    it 'has the same base_id' do
      expect(reversed.base_id).to be true
    end
  end

  context '.than_op' do
    it 'returns ">"' do
      expect(subject.than_op).to eq '>'
    end
  end

  context '.than_sql' do
    it 'returns "posts"."created_at" > :order_field1' do
      expect(subject.than_sql).to eq '"posts"."created_at" > :order_field1'
    end
  end

  context '.than_or_equal_op' do
    it 'returns ">="' do
      expect(subject.than_or_equal_op).to eq '>='
    end
  end

  context '.than_or_equal_sql' do
    it 'returns "posts"."created_at" >= :order_field1' do
      expect(subject.than_or_equal_sql).to eq '"posts"."created_at" >= :order_field1'
    end
  end
end