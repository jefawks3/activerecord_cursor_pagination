RSpec.describe ActiverecordCursorPagination::SecretKeyFinder do
  describe '.find_in' do
    context 'when using rails credentials' do
      let(:app) { OpenStruct.new credentials: OpenStruct.new(secret_key_base: '123') }

      it 'returns the key' do
        expect(subject.find_in(app)).to eq '123'
      end
    end

    context 'when using rails secrets' do
      let(:app) { OpenStruct.new secrets: OpenStruct.new(secret_key_base: '456') }

      it 'returns the key' do
        expect(subject.find_in(app)).to eq '456'
      end
    end

    context 'when using rails configuration' do
      let(:app) { OpenStruct.new config: OpenStruct.new(secret_key_base: '789') }

      it 'returns the key' do
        expect(subject.find_in(app)).to eq '789'
      end
    end

    context 'when at the root of the application' do
      let(:app) { OpenStruct.new secret_key_base: 'abc' }

      it 'returns the key' do
        expect(subject.find_in(app)).to eq 'abc'
      end
    end
  end
end