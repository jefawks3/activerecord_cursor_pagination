RSpec.describe ActiverecordCursorPagination::Cursor do
  subject :cursor do
    ActiverecordCursorPagination::Cursor.new Post,
                                             Post.where(published: true).order(created_at: :desc),
                                             100,
                                             1,
                                             100
  end

  describe '.empty?' do
    it 'returns false' do
      expect(subject.empty?).to be false
    end
  end

  describe '.present?' do
    it 'returns true' do
      expect(subject.present?).to be true
    end
  end

  describe '.to_hash' do
    it 'returns a hash representation' do
      expect(subject.to_hash).to include(per_page: 100, start: 1, end: 100, sql: 'ly/bDcwQzU2t3J1BeOp3nXjq4Lk=', model: 'Post')
    end
  end

  describe '.to_s' do
    it 'returns a serialized cursor' do
      expect(subject.to_s).to eq 'oN3XIhu0eLUj45SCXeAnHV+I8sQObxE1dTWTczsjBpGAkOz2m8G8v07jCtXMsok3uSY++e1cjZ77c+emVK5xo714LLjuCwJ68dc4nhxpyEhIvYKfwpPvtd3rmGCEHhps'
    end
  end

  describe 'validate!' do
    context 'when valid' do
      it 'does not raise error' do
        expect(subject.validate!(Post, Post.where(published: true).order(created_at: :desc), 100)).to be_nil
      end
    end

    context 'when klass invalid' do
      it 'raises InvalidCursorError' do
        expect {
          subject.validate!(String, Post.where(published: true).order(created_at: :desc), 100)
        }.to raise_error(ActiverecordCursorPagination::InvalidCursorError)
      end
    end

    context 'when sql invalid' do
      it 'raises InvalidCursorError' do
        expect {
          subject.validate!(Post, Post.where(published: false).order(created_at: :asc), 100)
        }.to raise_error(ActiverecordCursorPagination::InvalidCursorError)
      end
    end

    context 'when per_page invalid' do
      it 'raises InvalidCursorError' do
        expect {
          subject.validate!(Post, Post.where(published: true).order(created_at: :desc), 200)
        }.to raise_error(ActiverecordCursorPagination::InvalidCursorError)
      end
    end

    context 'when all invalid' do
      it 'raises InvalidCursorError' do
        expect {
          subject.validate!(String, Post.where(published: false).order(created_at: :asc), 1)
        }.to raise_error(ActiverecordCursorPagination::InvalidCursorError)
      end
    end
  end

  describe '#parse' do
    subject { ActiverecordCursorPagination::Cursor }

    context 'cursor is nil' do
      it 'is an instance of EmptyCursor' do
        expect(subject.parse(nil)).to be_an_instance_of(ActiverecordCursorPagination::EmptyCursor)
      end
    end

    context 'cursor is empty string' do
      it 'is an instance of EmptyCursor' do
        expect(subject.parse('')).to be_an_instance_of(ActiverecordCursorPagination::EmptyCursor)
      end
    end

    context 'cursor is valid' do
      subject { ActiverecordCursorPagination::Cursor.parse 'oN3XIhu0eLUj45SCXeAnHV+I8sQObxE1dTWTczsjBpGAkOz2m8G8v07jCtXMsok3uSY++e1cjZ77c+emVK5xo714LLjuCwJ68dc4nhxpyEhIvYKfwpPvtd3rmGCEHhps' }

      it 'has klass_name of "Post"' do
        expect(subject.klass_name).to eq 'Post'
      end

      it 'has signed_sql of "ly/bDcwQzU2t3J1BeOp3nXjq4Lk="' do
        expect(subject.signed_sql).to eq 'ly/bDcwQzU2t3J1BeOp3nXjq4Lk='
      end

      it 'has per_page of 100' do
        expect(subject.per_page).to be 100
      end

      it 'has start_id of 1' do
        expect(subject.start_id).to be 1
      end

      it 'has end_id of 100' do
        expect(subject.end_id).to be 100
      end
    end
  end

  describe '#to_param' do
    it 'returns a serialized cursor' do

    end
  end
end