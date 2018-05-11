module BlockStack
  class Query
    class RequiredGroup < GroupComponent

      def to_s
        to_s_array.join(' AND ')
      end

      def match?(object)
        expressions.all? { |expression| expression.match?(object) }
      end

      protected

      def analyze
        self.expressions = original_expression.map { |expression| Query.parse_requirements(expression) }
      end
    end
  end
end
