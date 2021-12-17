# frozen_string_literal: true

RSpec.describe ActiverecordCursorPagination::Cursor do
  subject :cursor do
    described_class.new Post,
                        Post.where(published: true).order(created_at: :desc),
                        100,
                        1,
                        100
  end

  describe ".empty?" do
    it "returns false" do
      expect(cursor.empty?).to be false
    end
  end

  describe ".present?" do
    it "returns true" do
      expect(cursor.present?).to be true
    end
  end

  describe ".to_hash" do
    it "returns a hash representation" do
      expect(cursor.to_hash).to include(per_page: 100, start: 1, end: 100, sql: "ly/bDcwQzU2t3J1BeOp3nXjq4Lk=", model: "Post")
    end
  end

  describe ".to_s" do
    it "returns a serialized cursor" do
      expect(cursor.to_s).to eq "oN3XIhu0eLUj45SCXeAnHV+I8sQObxE1dTWTczsjBpGAkOz2m8G8v07jCtXMsok3uSY++e1cjZ77c+emVK5xo714LLjuCwJ68dc4nhxpyEhIvYKfwpPvtd3rmGCEHhps"
    end
  end

  describe "validate!" do
    context "when valid" do
      it "does not raise error" do
        expect(cursor.validate!(Post, Post.where(published: true).order(created_at: :desc), 100)).to be_nil
      end
    end

    context "when klass invalid" do
      it "raises InvalidCursorError" do
        expect do
          cursor.validate!(String, Post.where(published: true).order(created_at: :desc), 100)
        end.to raise_error(ActiverecordCursorPagination::InvalidCursorError)
      end
    end

    context "when sql invalid" do
      it "raises InvalidCursorError" do
        expect do
          cursor.validate!(Post, Post.where(published: false).order(created_at: :asc), 100)
        end.to raise_error(ActiverecordCursorPagination::InvalidCursorError)
      end
    end

    context "when per_page invalid" do
      it "raises InvalidCursorError" do
        expect do
          cursor.validate!(Post, Post.where(published: true).order(created_at: :desc), 200)
        end.to raise_error(ActiverecordCursorPagination::InvalidCursorError)
      end
    end

    context "when all invalid" do
      it "raises InvalidCursorError" do
        expect do
          cursor.validate!(String, Post.where(published: false).order(created_at: :asc), 1)
        end.to raise_error(ActiverecordCursorPagination::InvalidCursorError)
      end
    end
  end

  describe "#parse" do
    context "when cursor is nil" do
      it "is an instance of EmptyCursor" do
        expect(described_class.parse(nil)).to be_an_instance_of(ActiverecordCursorPagination::EmptyCursor)
      end
    end

    context "when cursor is empty string" do
      it "is an instance of EmptyCursor" do
        expect(described_class.parse("")).to be_an_instance_of(ActiverecordCursorPagination::EmptyCursor)
      end
    end

    context "when cursor is valid" do
      subject(:cursor) { described_class.parse "oN3XIhu0eLUj45SCXeAnHV+I8sQObxE1dTWTczsjBpGAkOz2m8G8v07jCtXMsok3uSY++e1cjZ77c+emVK5xo714LLjuCwJ68dc4nhxpyEhIvYKfwpPvtd3rmGCEHhps" }

      it 'has klass_name of "Post"' do
        expect(cursor.klass_name).to eq "Post"
      end

      it 'has signed_sql of "ly/bDcwQzU2t3J1BeOp3nXjq4Lk="' do
        expect(cursor.signed_sql).to eq "ly/bDcwQzU2t3J1BeOp3nXjq4Lk="
      end

      it "has per_page of 100" do
        expect(cursor.per_page).to be 100
      end

      it "has start_id of 1" do
        expect(cursor.start_id).to be 1
      end

      it "has end_id of 100" do
        expect(cursor.end_id).to be 100
      end
    end
  end

  describe "#to_param" do
    subject :cursor do
      described_class.to_param Post,
                               Post.where(published: true).order(created_at: :desc),
                               100,
                               1,
                               100
    end

    it "returns a serialized cursor" do
      expect(cursor).to eq "oN3XIhu0eLUj45SCXeAnHV+I8sQObxE1dTWTczsjBpGAkOz2m8G8v07jCtXMsok3uSY++e1cjZ77c+emVK5xo714LLjuCwJ68dc4nhxpyEhIvYKfwpPvtd3rmGCEHhps"
    end
  end
end
