# frozen_string_literal: true

RSpec.describe ActiverecordCursorPagination::Configuration do
  subject(:config) { described_class.new }

  describe ".serializer" do
    it "returns SecureCursorSerialization" do
      expect(config.serializer).to be(ActiverecordCursorPagination::SecureCursorSerializer)
    end
  end

  describe ".serializer_instance" do
    it "returns an instance of SecureCursorSerialization" do
      expect(config.serializer_instance).to be_an_instance_of(ActiverecordCursorPagination::SecureCursorSerializer)
    end
  end

  describe ".secret_key" do
    context "when no key can be found" do
      it "raises NoSecretKeyError" do
        expect { config.secret_key }.to raise_error(ActiverecordCursorPagination::NoSecretKeyError)
      end
    end

    # rubocop:disable RSpec/BeforeAfterAll
    context "when in rails application" do
      subject(:config) { described_class.new }

      before :context do
        rails_class = Class.new do
          class << self
            def application
              OpenStruct.new secret_key_base: "1234"
            end
          end
        end

        Object.const_set "Rails", rails_class
      end

      after :context do
        Object.send :remove_const, :Rails
      end

      it "returns the key" do
        expect(config.secret_key).to eq "1234"
      end
    end
    # rubocop:enable RSpec/BeforeAfterAll

    context "when explicitly set" do
      subject(:config) do
        sub = described_class.new
        sub.secret_key = "test1234"
        sub
      end

      it "returns assigned key" do
        expect(config.secret_key).to eql("test1234")
      end
    end
  end
end
