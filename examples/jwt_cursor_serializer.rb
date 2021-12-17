# frozen_string_literal: true

##
# Serialize the cursor as a JWT string
class JwtCursorSerializer < ActiverecordCursorPagination::Serializer
  def deserialize(str)
    data = JWT.decode str,
                      secret_key,
                      true,
                      { algorithm: "HS256" }

    data.first.symbolize_keys
  end

  def serialize(hash)
    JWT.encode hash, secret_key, "HS256"
  end
end
