module ActiverecordCursorPagination
  module Extension
    extend ActiveSupport::Concern

    module ClassMethods
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