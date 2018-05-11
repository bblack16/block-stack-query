module BlockStack
  class Query
    class QueryComponent
      include BBLib::Effortless
      include BBLib::TypeInit

      attr_str :original_expression, arg_at: 0, serialize: false

      after :original_expression=, :analyze

      def match?(object)
        false # Does nothing in parent class
      end

      protected

      def analyze
        raise AbstractMethodError
      end
    end
  end
end
