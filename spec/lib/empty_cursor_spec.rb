RSpec.describe ActiverecordCursorPagination::EmptyCursor do
  describe '.present?' do
    it 'returns false' do
      expect(subject.present?).to be false
    end
  end

  describe '.empty?' do
    it 'returns true' do
      expect(subject.empty?).to be true
    end
  end

  describe '.to_s' do
    it 'returns empty string' do
      expect(subject.to_s).to eq ''
    end
  end

  describe '.to_param' do
    it 'returns empty string' do
      expect(subject.to_s).to eq ''
    end
  end

  describe '#to_param' do
    it 'returns empty string' do
      expect(subject.to_param).to eq ''
    end
  end
end