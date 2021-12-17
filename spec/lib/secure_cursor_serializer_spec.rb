# frozen_string_literal: true

RSpec.describe ActiverecordCursorPagination::SecureCursorSerializer do
  subject(:serializer) { described_class.new }

  describe ".serialize" do
    it "returns serialized string" do
      hash = { page: 123, where: "id=2" }
      expect(serializer.serialize(hash)).to eql("FbSxx011SSwn1UINLu/nakfk9Y3JF3pelSqbZsmaAsU=")
    end
  end

  describe ".deserialize" do
    it "returns hash" do
      expect(serializer.deserialize("FbSxx011SSwn1UINLu/nakfk9Y3JF3pelSqbZsmaAsU=")).to include(
        page: 123,
        where: "id=2"
      )
    end
  end
end
