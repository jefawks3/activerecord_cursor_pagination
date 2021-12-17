# frozen_string_literal: true

module ActiverecordCursorPagination
  module Extension # :nodoc:
    extend ActiveSupport::Concern

    module ClassMethods # :nodoc:
      def inherited(kls)
        super
        kls.send :include, ModelExtension if kls.superclass == ActiveRecord::Base
      end
    end

    included do
      descendants.each do |kls|
        kls.send :include, ModelExtension if kls.superclass == ActiveRecord::Base
      end
    end
  end
end
