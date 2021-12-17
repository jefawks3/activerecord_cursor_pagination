# frozen_string_literal: true

module ActiverecordCursorPagination
  ##
  # Helper class to find the secret_key_base in a given application
  class SecretKeyFinder
    def find_in(application)
      if application.respond_to? :credentials
        application.credentials.secret_key_base
      elsif application.respond_to? :secrets
        application.secrets.secret_key_base
      elsif application.config.respond_to? :secret_key_base
        application.config.secret_key_base
      elsif application.respond_to? :secret_key_base
        application.secret_key_base
      end
    end
  end
end
