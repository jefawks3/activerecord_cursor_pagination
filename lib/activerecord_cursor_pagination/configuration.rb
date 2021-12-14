module ActiverecordCursorPagination
  class Configuration
    attr_accessor :serializer, :secret_key

    def initialize
      setup_defaults
    end

    ##
    # Gets the secret key base for secure cursor implementations.
    #
    # If Rails is defined, +secret_key+ will try to find the implementation of the default +secret_key_base+
    # in the application.
    #
    # @raise [NoSecretKeyError] If no key is set or found.
    #
    # @return [String] The secret key.
    def secret_key
      raise NoSecretKeyError, 'No secret key is defined' if @secret_key.nil? || @secret_key.empty?
      @secret_key
    end

    ##
    # Get an instance of the serializer
    #
    # @return [Serializer]
    def serializer_instance
      serializer.new
    end

    private

    def setup_defaults
      @secret_key = find_secret_key
      @serializer = SecureCursorSerializer
    end

    def find_secret_key
      return nil unless defined?(Rails) && Rails.respond_to?(:application)

      finder = SecretKeyFinder.new
      finder.find_in Rails.application
    end
  end
end