# frozen_string_literal: true

RSpec.describe ActiverecordCursorPagination::Extension do
  # rubocop:disable Rspec/BeforeAfterAll
  before :context do
    Post.delete_all
    ActiveRecord::Base.connection.execute "UPDATE `sqlite_sequence` SET `seq` = 0 WHERE `name` = 'posts';"

    20.times do
      Post.create! body: Faker::Lorem.paragraph, published: true
    end
  end

  after :context do
    Post.delete_all
  end
  # rubocop:enable Rspec/BeforeAfterAll

  describe ".cursor" do
    it "returns a cursor" do
      cursor = Post.cursor nil
      expect(cursor).to be_a ActiverecordCursorPagination::CursorScope
    end
  end

  describe ".cursor_batch" do
    it "iterates through each page" do
      count = 0
      Post.cursor_batch(batch_size: 10) { count += 1 }
      expect(count).to eq 2
    end

    it "passes the cursor for each page" do
      cursors = []
      Post.cursor_batch(batch_size: 10) { |cursor| cursors << cursor.current_cursor.to_s }
      expect(cursors).to match_array %w[oN3XIhu0eLUj45SCXeAnHSb6zWUyXje4bAzstNIRFtiyDY268vD1IuTSg4hdi7VAa5L/7dzKevQQpDWt1lsh42WlNRABfWNA4Xwsq9mA6ghbHp1HlO8JFS2mjXJJsBeu tu6f+KOzY6EB0m4qVw4zFuwSTGgNaqDXsCm2mLVvVw+fHquuFC0hTaOamh9x5Jx9j5q5uTL9Qsf8dIIOEvFbS61r2Ovl+bn7YUKKd+/VwArTWNzjBA2UfPM0tQTw9be5]
    end
  end

  describe ".cursor_batch_with_index" do
    it "iterates through each page" do
      count = 0
      Post.cursor_batch_with_index(batch_size: 10) { count += 1 }
      expect(count).to eq 2
    end

    it "passes the cursor for each page" do
      cursors = []
      Post.cursor_batch_with_index(batch_size: 10) { |cursor, index| cursors << [cursor.current_cursor.to_s, index] }
      expect(cursors).to match_array [["oN3XIhu0eLUj45SCXeAnHSb6zWUyXje4bAzstNIRFtiyDY268vD1IuTSg4hdi7VAa5L/7dzKevQQpDWt1lsh42WlNRABfWNA4Xwsq9mA6ghbHp1HlO8JFS2mjXJJsBeu", 0], ["tu6f+KOzY6EB0m4qVw4zFuwSTGgNaqDXsCm2mLVvVw+fHquuFC0hTaOamh9x5Jx9j5q5uTL9Qsf8dIIOEvFbS61r2Ovl+bn7YUKKd+/VwArTWNzjBA2UfPM0tQTw9be5", 1]]
    end
  end

  describe ".cursor_find_each" do
    it "iterates through each record" do
      count = 0
      Post.cursor_find_each(batch_size: 5) { count += 1 }
      expect(count).to eq 20
    end

    it "passes the cursor for each page" do
      posts = []
      Post.cursor_find_each(batch_size: 5) { |post| posts << post.id }
      expect(posts).to match_array [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
    end
  end

  describe ".cursor_find_each_with_index" do
    it "iterates through each record" do
      count = 0
      Post.cursor_find_each_with_index(batch_size: 5) { count += 1 }
      expect(count).to eq 20
    end

    it "passes the cursor for each page" do
      posts = []
      Post.cursor_find_each_with_index(batch_size: 5) { |post, index| posts << [post.id, index] }
      expect(posts).to match_array [[1, 0], [2, 1], [3, 2], [4, 3], [5, 4], [6, 5], [7, 6], [8, 7], [9, 8], [10, 9], [11, 10], [12, 11], [13, 12], [14, 13], [15, 14], [16, 15], [17, 16], [18, 17], [19, 18], [20, 19]]
    end
  end
end
