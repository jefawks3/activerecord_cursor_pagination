# frozen_string_literal: true

RSpec.describe ActiverecordCursorPagination::Serializer do
  subject(:serializer) { described_class.new }

  describe ".serialize" do
    it "raises NotImplementedError" do
      expect { serializer.serialize({}) }.to raise_error(NotImplementedError)
    end
  end

  describe ".deserialize" do
    it "raises NotImplementedError" do
      expect { serializer.deserialize("") }.to raise_error(NotImplementedError)
    end
  end
end
