# frozen_string_literal: true

module ActiverecordCursorPagination
  ##
  # Generate a signature based on the SQL query
  class SqlSigner
    ##
    # Sign SQL
    #
    # @param [ActiveRecord::Relation, nil] sql The SQL to sign.
    #
    # @return [String] The signature hash.
    def sign(sql)
      return nil if sql.nil?

      sql = format sql
      digest = OpenSSL::Digest.new "sha1"
      hmac = OpenSSL::HMAC.digest digest, secret_key, sql
      hash = Base64.encode64 hmac
      hash.gsub(/\n+/, "")
    end

    private

    def secret_key
      ActiverecordCursorPagination.configuration.secret_key
    end

    def format(sql)
      sql_str = sql.only(:joins, :where, :order).to_sql
      sql_str.gsub(/[\s\t]*/, " ").gsub(/\n+/, " ")
    end
  end
end
