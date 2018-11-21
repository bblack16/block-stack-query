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
        expressions = original_expression
        if matches = original_expression.find_all { |exp| OPERATORS[:between].any? { |op| exp.qsplit(' ')[-2] == op } }
          matches.each do |match|
            index = expressions.index(match)
            expressions[index] = [match, expressions.delete_at(index + 1)].join('..')
          end
        end
        self.expressions = expressions.map { |expression| Query.parse_requirements(expression) }
      end
    end
  end
end
