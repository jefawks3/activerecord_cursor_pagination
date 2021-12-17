# frozen_string_literal: true

RSpec.describe ActiverecordCursorPagination::EmptyCursor do
  subject(:cursor) { described_class.new }

  describe ".present?" do
    it "returns false" do
      expect(cursor.present?).to be false
    end
  end

  describe ".empty?" do
    it "returns true" do
      expect(cursor.empty?).to be true
    end
  end

  describe ".to_s" do
    it "returns empty string" do
      expect(cursor.to_s).to eq ""
    end
  end

  describe ".to_param" do
    it "returns empty string" do
      expect(cursor.to_param).to eq ""
    end
  end

  describe "#to_param" do
    it "returns empty string" do
      expect(described_class.to_param).to eq ""
    end
  end
end
