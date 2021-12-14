module ActiverecordCursorPagination
  ##
  # Secure cursor serializer implementation using AES 256 encryption.
  class SecureCursorSerializer < Serializer
    ##
    # Deserializes the secure cursor.
    #
    # @param [String] str The AES encrypted serialized JSON string.
    #
    # @return [Hash]
    def deserialize(str)
      c = cipher.decrypt
      c.key = cipher_key
      decoded = Base64.strict_decode64 str
      decrypted = c.update(decoded) + c.final
      json = JSON.parse decrypted
      json.symbolize_keys
    end

    ##
    # Serializes and secures the hash representation of a cursor.
    #
    # @param [Hash] hash The hash representation of a cursor.
    #
    # @return [String] The encrypted cursor string.
    def serialize(hash)
      c = cipher.encrypt
      c.key = cipher_key
      json = JSON.generate hash
      encrypted = c.update(json) + c.final
      Base64.strict_encode64 encrypted
    end

    private

    def cipher
      OpenSSL::Cipher.new 'aes-256-cbc'
    end

    def cipher_key
      Digest::SHA256.digest secret_key
    end
  end
end
