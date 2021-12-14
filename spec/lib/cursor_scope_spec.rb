RSpec.describe ActiverecordCursorPagination::CursorScope do
  before :context do
    # Ensure we get consistent cursors
    Post.delete_all
    ActiveRecord::Base.connection.execute "UPDATE `sqlite_sequence` SET `seq` = 0 WHERE `name` = 'posts';"

    (0..100).each do |i|
      Post.create! body: Faker::Lorem.paragraph, published: i % 7 != 0
    end
  end

  after :context do
    Post.delete_all
  end

  let(:default_query) { Post.where(published: true).order(created_at: :desc) }
  let(:empty_query) { Post.where('created_at < :date', date: Time.now - 1.year).order(created_at: :asc) }
  let(:single_query) { Post.where('id >= :id', id: Post.last.id).order(created_at: :asc) }

  subject do
    ActiverecordCursorPagination::CursorScope.new Post, default_query, nil, per: 10
  end

  let :empty_subject do
    ActiverecordCursorPagination::CursorScope.new Post, empty_query, nil, per: 10
  end

  let :single_subject do
    ActiverecordCursorPagination::CursorScope.new Post, single_query, nil, per: 10
  end

  let :single_record_scoped_subject do
    ActiverecordCursorPagination::CursorScope.new Post, default_query, Post.find(80), per: 1
  end

  let :first_page_subject do
    ActiverecordCursorPagination::CursorScope.new Post, default_query, '1LApYQ0cIJawthNSn6OXbmEFQwb7SS99WBsgBSFGqE7gV4099l5a7qkuLkuDnZBJC9ckN61klw1X/OyGMnFcrYhugAcmWdWJ5cxEO8mzIfktm+lGRmJDks+yzJD8hybP', per: 10
  end

  let :second_page_subject do
    ActiverecordCursorPagination::CursorScope.new Post, default_query, '6hT2IhaiLHq+4AW9Wp9fr6PesPUPnPts9T7H9eThRzwsB6w8sDdvsKyTtCJYhyiZrKH0uvtPwv3DFe4v+7AonkVRzF8s73IJQC55C18SOCupPUfz5pCR25RSnAW/1hVf', per: 10
  end

  let :last_page_subject do
    cursor = "DwGGd6xZ1F+xNXkuZ4L4EKa5Sh+c55engScintZ1PaWLjUR7YHln4n7Rq/wDrfHojO0djtdCQ9jnIRF/w7WWCMSDYbG6IYT42gFwzZR5X8ePWwTl227hnST6raF+edUu"
    ActiverecordCursorPagination::CursorScope.new Post, default_query, cursor, per: 10
  end

  let :record_subject do
    ActiverecordCursorPagination::CursorScope.new Post, default_query, Post.find(50), per: 10
  end

  describe '.initialize' do
    context 'invalid cursor' do
      let(:invalid_cursor) do
        ActiverecordCursorPagination::Cursor.new Post,
                                                 Post.where(published: false),
                                                 100,
                                                 1,
                                                 100
      end

      it 'raises InvalidCursorError' do
        expect {
          ActiverecordCursorPagination::CursorScope.new Post, default_query, invalid_cursor, per: 20
        }.to raise_error(ActiverecordCursorPagination::InvalidCursorError)
      end
    end

    context 'invalid cursor type' do
      it 'raises InvalidCursorError' do
        expect {
          ActiverecordCursorPagination::CursorScope.new Post, default_query, 1, per: 20
        }.to raise_error(ActiverecordCursorPagination::InvalidCursorError)
      end
    end
  end

  describe '.per_page' do
    it 'is the same as the argument per' do
      expect(subject.per_page).to be 10
    end
  end

  describe '.single_record?' do
    context 'when per page = 1' do
      subject { ActiverecordCursorPagination::CursorScope.new Post, default_query, nil, per: 1 }

      it 'returns true' do
        expect(subject.single_record?).to be true
      end
    end

    context 'when per page > 1' do
      subject { ActiverecordCursorPagination::CursorScope.new Post, default_query, nil, per: 10 }

      it 'returns true' do
        expect(subject.single_record?).to be false
      end
    end
  end

  describe '.scope_size' do
    it 'returns 86' do
      expect(subject.scope_size).to be 86
    end
  end

  describe '.scope_count' do
    it 'returns 86' do
      expect(subject.scope_count).to be 86
    end
  end

  describe '.total_count' do
    it 'returns 86' do
      expect(subject.total_count).to be 86
    end
  end

  describe '.total' do
    it 'returns 86' do
      expect(subject.total).to be 86
    end
  end

  describe '.scope_empty?' do
    context 'when records are found' do
      it 'returns false' do
        expect(subject.scope_empty?).to be false
      end
    end

    context 'when no records are found' do
      it 'returns true' do
        expect(empty_subject.scope_empty?).to be true
      end
    end
  end

  describe '.scope_none?' do
    context 'when records are found' do
      it 'returns false' do
        expect(subject.scope_none?).to be false
      end
    end

    context 'when no records are found' do
      it 'returns true' do
        expect(empty_subject.scope_none?).to be true
      end
    end
  end

  describe '.scope_any?' do
    context 'when records are found' do
      it 'returns true' do
        expect(subject.scope_any?).to be true
      end
    end

    context 'when no records are found' do
      it 'returns true' do
        expect(empty_subject.scope_any?).to be false
      end
    end
  end

  describe '.scope_one?' do
    context 'when only one record is found' do
      it 'returns true' do
        expect(single_subject.scope_one?).to be true
      end
    end

    context 'when many records are found' do
      it 'returns false' do
        expect(subject.scope_one?).to be false
      end
    end

    context 'when no records are found' do
      it 'returns false' do
        expect(empty_subject.scope_one?).to be false
      end
    end
  end

  describe '.scope_many?' do
    context 'when only one record is found' do
      it 'returns false' do
        expect(single_subject.scope_many?).to be false
      end
    end

    context 'when many records are found' do
      it 'returns true' do
        expect(subject.scope_many?).to be true
      end
    end

    context 'when no records are found' do
      it 'returns false' do
        expect(empty_subject.scope_many?).to be false
      end
    end
  end

  describe '.size' do
    context 'when only one record is found' do
      it 'returns 1' do
        expect(single_subject.size).to be 1
      end
    end

    context 'when many records are found' do
      it 'returns 10' do
        expect(subject.size).to be 10
      end
    end

    context 'when on the last page' do
      it 'returns 6' do
        expect(last_page_subject.size).to be 6
      end
    end

    context 'when no records are found' do
      it 'returns zero' do
        expect(empty_subject.size).to be 0
      end
    end
  end

  describe '.count' do
    context 'when only one record is found' do
      it 'returns one' do
        expect(single_subject.count).to be 1
      end
    end

    context 'when many records are found' do
      it 'returns 10' do
        expect(subject.count).to be 10
      end
    end

    context 'when on the last page' do
      it 'returns 6' do
        expect(last_page_subject.count).to be 6
      end
    end

    context 'when no records are found' do
      it 'returns zero' do
        expect(empty_subject.count).to be 0
      end
    end
  end

  describe '.length' do
    context 'when only one record is found' do
      it 'returns one' do
        expect(single_subject.length).to be 1
      end
    end

    context 'when many records are found' do
      it 'returns 10' do
        expect(subject.length).to be 10
      end
    end

    context 'when on the last page' do
      it 'returns 6' do
        expect(last_page_subject.length).to be 6
      end
    end

    context 'when no records are found' do
      it 'returns zero' do
        expect(empty_subject.length).to be 0
      end
    end
  end

  describe '.empty?' do
    context 'when many records are found' do
      it 'returns false' do
        expect(subject.empty?).to be false
      end
    end

    context 'when no records are found' do
      it 'returns true' do
        expect(empty_subject.empty?).to be true
      end
    end
  end

  describe '.none?' do
    context 'when many records are found' do
      it 'returns false' do
        expect(subject.none?).to be false
      end
    end

    context 'when no records are found' do
      it 'returns true' do
        expect(empty_subject.none?).to be true
      end
    end
  end

  describe '.any?' do
    context 'when only one record is found' do
      it 'returns true' do
        expect(single_subject.any?).to be true
      end
    end

    context 'when many records are found' do
      it 'returns true' do
        expect(subject.any?).to be true
      end
    end

    context 'when no records are found' do
      it 'returns false' do
        expect(empty_subject.any?).to be false
      end
    end
  end

  describe '.many?' do
    context 'when only one record is found' do
      it 'returns false' do
        expect(single_subject.many?).to be false
      end
    end

    context 'when many records are found' do
      it 'returns true' do
        expect(subject.many?).to be true
      end
    end

    context 'when no records are found' do
      it 'returns false' do
        expect(empty_subject.many?).to be false
      end
    end
  end

  describe '.one?' do
    context 'when only one record is found' do
      it 'returns true' do
        expect(single_subject.one?).to be true
      end
    end

    context 'when many records are found' do
      it 'returns false' do
        expect(subject.one?).to be false
      end
    end

    context 'when no records are found' do
      it 'returns false' do
        expect(empty_subject.one?).to be false
      end
    end
  end

  describe '.previous_page?' do
    context 'when first page' do
      it 'returns false' do
        expect(subject.previous_page?).to be false
      end
    end

    context 'when last page' do
      it 'returns true' do
        expect(last_page_subject.previous_page?).to be true
      end
    end

    context 'when empty scope' do
      it 'returns false' do
        expect(empty_subject.previous_page?).to be false
      end
    end

    context 'when single record' do
      it 'returns false' do
        expect(single_subject.previous_page?).to be false
      end
    end
  end

  describe '.next_page?' do
    context 'when first page' do
      it 'returns true' do
        expect(subject.next_page?).to be true
      end
    end

    context 'when last page' do
      it 'returns false' do
        expect(last_page_subject.next_page?).to be false
      end
    end

    context 'when empty scope' do
      it 'returns false' do
        expect(empty_subject.next_page?).to be false
      end
    end

    context 'when single record' do
      it 'returns false' do
        expect(single_subject.next_page?).to be false
      end
    end
  end

  describe '.first_page?' do
    context 'when first page' do
      it 'returns true' do
        expect(subject.first_page?).to be true
      end
    end

    context 'when last page' do
      it 'returns false' do
        expect(last_page_subject.first_page?).to be false
      end
    end

    context 'when empty scope' do
      it 'returns true' do
        expect(empty_subject.first_page?).to be true
      end
    end

    context 'when single record' do
      it 'returns true' do
        expect(single_subject.first_page?).to be true
      end
    end
  end

  describe '.last_page?' do
    context 'when first page' do
      it 'returns false' do
        expect(subject.last_page?).to be false
      end
    end

    context 'when last page' do
      it 'returns true' do
        expect(last_page_subject.last_page?).to be true
      end
    end

    context 'when empty scope' do
      it 'returns true' do
        expect(empty_subject.last_page?).to be true
      end
    end

    context 'when single record' do
      it 'returns true' do
        expect(single_subject.last_page?).to be true
      end
    end
  end

  describe '.current_cursor' do
    context 'when nil passed' do
      it 'returns serialized cursor' do
        expect(subject.current_cursor).to eq '1LApYQ0cIJawthNSn6OXbmEFQwb7SS99WBsgBSFGqE7gV4099l5a7qkuLkuDnZBJC9ckN61klw1X/OyGMnFcrYhugAcmWdWJ5cxEO8mzIfktm+lGRmJDks+yzJD8hybP'
      end
    end

    context 'when serialized cursor is passed' do
      it 'returns serialized cursor' do
        expect(last_page_subject.current_cursor).to eq 'DwGGd6xZ1F+xNXkuZ4L4EKa5Sh+c55engScintZ1PaWLjUR7YHln4n7Rq/wDrfHojO0djtdCQ9jnIRF/w7WWCMSDYbG6IYT42gFwzZR5X8ePWwTl227hnST6raF+edUu'
      end
    end

    context 'when a record is passed' do
      it 'returns serialized cursor' do
        expect(record_subject.current_cursor).to eq 'uzWWRomOl9z2f1hWr8IQwca0WKlz/IvLgwQnIgaMCZbMSIRScdRYqp6bAxD0jjzq9vOhYgmYer2gewjtXIT9Xfnn9lostW5uO7iKd2Jq4QrgLskGKZcXM9T+dkSgixke'
      end
    end

    context 'when a using a single record scope' do
      it 'returns serialized cursor' do
        expect(single_record_scoped_subject.current_cursor).to eq 'rjTAV8tbBRlv+GFWVNUDorPmrTiPhGdFp4FiVaeNR1J6KiNbsBscG5vfyZZ4OluJ6KoaZRooD6WlFYLyG8/j8GQ+qhtByPYwvk2RJQLPnQuZI2viGRdp8XyPR9ftV6Y4'
      end
    end

    context 'when empty scope' do
      it 'returns empty string' do
        expect(empty_subject.current_cursor).to eql ''
      end
    end

    context 'when record deleted inside cursor range' do
      before do
        Post.find(95).destroy
      end

      it 'does not change cursor' do
        expect(first_page_subject.current_cursor).to eq '1LApYQ0cIJawthNSn6OXbmEFQwb7SS99WBsgBSFGqE7gV4099l5a7qkuLkuDnZBJC9ckN61klw1X/OyGMnFcrYhugAcmWdWJ5cxEO8mzIfktm+lGRmJDks+yzJD8hybP'
      end
    end
  end

  describe '.next_cursor' do
    context 'when first page' do
      it 'returns serialized cursor' do
        expect(subject.next_cursor).to eq '6hT2IhaiLHq+4AW9Wp9fr6PesPUPnPts9T7H9eThRzwsB6w8sDdvsKyTtCJYhyiZrKH0uvtPwv3DFe4v+7AonkVRzF8s73IJQC55C18SOCupPUfz5pCR25RSnAW/1hVf'
      end
    end

    context 'when last page' do
      it 'returns empty string' do
        expect(last_page_subject.next_cursor).to eql ''
      end
    end

    context 'when empty scope' do
      it 'returns empty string' do
        expect(empty_subject.next_cursor).to eql ''
      end
    end

    context 'when record deleted inside cursor range' do
      before do
        Post.find(95).destroy
      end

      it 'does not change cursor' do
        expect(first_page_subject.next_cursor).to eq '6hT2IhaiLHq+4AW9Wp9fr6PesPUPnPts9T7H9eThRzwsB6w8sDdvsKyTtCJYhyiZrKH0uvtPwv3DFe4v+7AonkVRzF8s73IJQC55C18SOCupPUfz5pCR25RSnAW/1hVf'
      end
    end
  end

  describe '.next_cursor_record' do
    context 'when not a single record scope' do
      it 'raises NotSingleRecordError' do
        expect { subject.next_cursor_record }.to raise_error(ActiverecordCursorPagination::NotSingleRecordError)
      end
    end

    context 'when single record' do
      it 'returns the next record' do
        expect(single_record_scoped_subject.next_cursor_record).to eq Post.find(79)
      end
    end
  end

  describe '.previous_cursor' do
    context 'when first page' do
      it 'returns empty string' do
        expect(subject.previous_cursor).to eq ''
      end
    end

    context 'when last page' do
      it 'returns serialized cursor' do
        expect(last_page_subject.previous_cursor).to eq 'afuy3RB8X9XYItLR78EVpcZs24tFLqNHD33lLJMIzhc75SLDUO2nrymwkHm9H1GSJdY/HeTLwObS+ugUK6LI9a8AckGpE0fn+21JpiXqo7Hez7E+WefaaBwWI/3bhzp+'
      end
    end

    context 'when empty scope' do
      it 'returns empty string' do
        expect(empty_subject.previous_cursor).to eq ''
      end
    end

    context 'when record deleted inside cursor range' do
      before do
        Post.find(85).destroy
      end

      it 'does not change cursor' do
        expect(second_page_subject.previous_cursor).to eq '1LApYQ0cIJawthNSn6OXbmEFQwb7SS99WBsgBSFGqE7gV4099l5a7qkuLkuDnZBJC9ckN61klw1X/OyGMnFcrYhugAcmWdWJ5cxEO8mzIfktm+lGRmJDks+yzJD8hybP'
      end
    end
  end

  describe '.previous_cursor_record' do
    context 'when not a single record scope' do
      it 'raises NotSingleRecordError' do
        expect { subject.previous_cursor_record }.to raise_error(ActiverecordCursorPagination::NotSingleRecordError)
      end
    end

    context 'when single record' do
      it 'returns the next record' do
        expect(single_record_scoped_subject.previous_cursor_record).to eq Post.find(81)
      end
    end
  end

  describe '.each' do
    it 'executes for each record' do
      count = 0
      subject.each { |r| count += 1 }
      expect(count).to be 10
    end

    it 'passes each record in the page' do
      records = []
      subject.each { |r| records << r.id }
      expect(records).to match_array [90, 91, 93, 94, 95, 96, 97, 98, 100, 101]
    end
  end

  describe '.each_with_index' do
    it 'executes for each record' do
      count = 0
      subject.each_with_index { |r, i| count += 1 }
      expect(count).to be 10
    end

    it 'passes each record in the page' do
      records = []
      subject.each_with_index { |r, i| records << [r.id, i] }
      expect(records).to match_array [[90, 9], [91, 8], [93, 7], [94, 6], [95, 5], [96, 4], [97, 3], [98, 2], [100, 1], [101, 0]]
    end
  end

  describe '.map' do
    it 'executes for each record' do
      count = 0
      subject.map { |r| count += 1 }
      expect(count).to be 10
    end

    it 'passes each record in the page' do
      records = subject.map &:id
      expect(records).to match_array [90, 91, 93, 94, 95, 96, 97, 98, 100, 101]
    end
  end

  describe '.map_with_index' do
    it 'executes for each record' do
      count = 0
      subject.map_with_index { |r, i| count += 1 }
      expect(count).to be 10
    end

    it 'passes each record in the page' do
      records = subject.map_with_index { |r, i| [r.id, i] }
      expect(records).to match_array [[90, 9], [91, 8], [93, 7], [94, 6], [95, 5], [96, 4], [97, 3], [98, 2], [100, 1], [101, 0]]
    end
  end
end