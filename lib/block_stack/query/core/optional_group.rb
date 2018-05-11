module BlockStack
  class Query
    class OptionalGroup < GroupComponent

      def to_s
        to_s_array.join(' OR ')
      end

      def match?(object)
        expressions.any? { |expression| expression.match?(object) }
      end

      protected

      def analyze
        self.expressions = original_expression.map { |expression| Query.parse_requirements(expression) }
      end
    end
  end
end
