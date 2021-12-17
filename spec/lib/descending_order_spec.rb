# frozen_string_literal: true

RSpec.describe ActiverecordCursorPagination::DescendingOrder do
  subject :order do
    order = described_class.new "posts", "created_at", 1
    order.base_id = true
    order
  end

  describe ".direction" do
    it "returns asc" do
      expect(order.direction).to be :desc
    end
  end

  describe ".reverse" do
    let(:reversed) { order.reverse }

    it "is a DescendingOrder" do
      expect(reversed).to be_a ActiverecordCursorPagination::AscendingOrder
    end

    it "has same table name" do
      expect(reversed.table).to eq "posts"
    end

    it "has same column name" do
      expect(reversed.name).to eq "created_at"
    end

    it "has the same index" do
      expect(reversed.index).to eq 1
    end

    it "has the same base_id" do
      expect(reversed.base_id).to be true
    end
  end

  describe ".than_op" do
    it 'returns "<"' do
      expect(order.than_op).to eq "<"
    end
  end

  describe ".than_sql" do
    it 'returns "posts"."created_at" < :order_field1' do
      expect(order.than_sql).to eq '"posts"."created_at" < :order_field1'
    end
  end

  describe ".than_or_equal_op" do
    it 'returns ">="' do
      expect(order.than_or_equal_op).to eq "<="
    end
  end

  describe ".than_or_equal_sql" do
    it 'returns "posts"."created_at" <= :order_field1' do
      expect(order.than_or_equal_sql).to eq '"posts"."created_at" <= :order_field1'
    end
  end
end
