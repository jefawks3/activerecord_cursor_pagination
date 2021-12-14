RSpec.describe ActiverecordCursorPagination::ClassFormatter do
  describe '.format' do
    context 'when passed a Class' do
      it 'returns class name' do
        expect(subject.format(Post)).to eq('Post')
      end
    end

    context 'when passed a String' do
      it 'returns the String' do
        expect(subject.format('Post')).to eq('Post')
      end
    end

    context 'when passed a Symbol' do
      it 'returns the camelcase string' do
        expect(subject.format(:post)).to eq('Post')
      end
    end
  end
end