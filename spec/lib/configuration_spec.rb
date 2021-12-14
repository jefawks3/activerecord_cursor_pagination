RSpec.describe ActiverecordCursorPagination::Configuration do
  describe '.serializer' do
    it 'returns SecureCursorSerialization' do
      expect(subject.serializer).to be(ActiverecordCursorPagination::SecureCursorSerializer)
    end
  end

  describe '.serializer_instance' do
    it 'returns an instance of SecureCursorSerialization' do
      expect(subject.serializer_instance).to be_an_instance_of(ActiverecordCursorPagination::SecureCursorSerializer)
    end
  end

  describe '.secret_key' do
    context 'with default configuration' do
      context 'when no key can be found' do
        it 'raises NoSecretKeyError' do
          expect { subject.secret_key }.to raise_error(ActiverecordCursorPagination::NoSecretKeyError)
        end
      end

      context 'when in rails application' do
        before :context do
          rails_class = Class.new do
            class << self
              def application
                OpenStruct.new secret_key_base: '1234'
              end
            end
          end

          Object.const_set 'Rails', rails_class
        end

        after :context do
          Object.send :remove_const, :Rails
        end

        subject { ActiverecordCursorPagination::Configuration.new }

        it 'returns the key' do
          expect(subject.secret_key).to eq '1234'
        end
      end
    end

    context 'when explicitly set' do
      subject do
        sub = ActiverecordCursorPagination::Configuration.new
        sub.secret_key = 'test1234'
        sub
      end

      it 'returns assigned key' do
        expect(subject.secret_key).to eql('test1234')
      end
    end
  end
end