# frozen_string_literal: true

RSpec.describe ActiverecordCursorPagination::ClassFormatter do
  subject(:formatter) { described_class.new }

  describe ".format" do
    context "when passed a Class" do
      it "returns class name" do
        expect(formatter.format(Post)).to eq("Post")
      end
    end

    context "when passed a String" do
      it "returns the String" do
        expect(formatter.format("Post")).to eq("Post")
      end
    end

    context "when passed a Symbol" do
      it "returns the camelcase string" do
        expect(formatter.format(:post)).to eq("Post")
      end
    end
  end
end
