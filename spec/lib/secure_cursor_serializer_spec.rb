RSpec.describe ActiverecordCursorPagination::SecureCursorSerializer do
  describe '.serialize' do
    it 'returns serialized string' do
      expect(subject.serialize({page: 123, where: 'id=2'})).to eql('FbSxx011SSwn1UINLu/nakfk9Y3JF3pelSqbZsmaAsU=')
    end
  end

  describe '.deserialize' do
    it 'returns hash' do
      expect(subject.deserialize('FbSxx011SSwn1UINLu/nakfk9Y3JF3pelSqbZsmaAsU=')).to include(page: 123, where: 'id=2')
    end
  end
end