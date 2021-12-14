RSpec.describe ActiverecordCursorPagination::Serializer do
  describe '.serialize' do
    it 'raises NotImplementedError' do
      expect { subject.serialize({}) }.to raise_error(NotImplementedError)
    end
  end

  describe '.deserialize' do
    it 'raises NotImplementedError' do
      expect { subject.deserialize({}) }.to raise_error(NotImplementedError)
    end
  end

end