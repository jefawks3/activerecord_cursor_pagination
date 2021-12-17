# frozen_string_literal: true

module ActiverecordCursorPagination
  ##
  # Cursor serializer base class.
  #
  # @abstract
  class Serializer
    ##
    # Deserialize the cursor.
    #
    # @abstract
    #
    # @param [String] str The serialized cursor string.
    #
    # @return [Hash] a hash representation of the cursor.
    def deserialize(str)
      raise NotImplementedError
    end

    ##
    # Serialize the hash representation of the cursor.
    #
    # @abstract
    #
    # @param [Hash] hash The hash representation of the cursor.
    #
    # @return [String] the serialized cursor string.
    def serialize(hash)
      raise NotImplementedError
    end

    protected

    ##
    # Gets the secret key for the application.
    #
    # @raise [NoSecretKeyDefined] if the key is not defined.
    #
    # @return [String] if the key is defined.
    def secret_key
      ActiverecordCursorPagination.configuration.secret_key
    end
  end
end
