module BlockStack
  class Query
    class GroupComponent < QueryComponent

      attr_ary_of [String], :original_expression, arg_at: 0
      attr_ary_of [QueryComponent], :expressions

      protected

      def to_s_array
        expressions.map do |expression|
          if expression.is_a?(Expression)
            expression.to_s
          else
            "(#{expression.to_s})"
          end
        end
      end
    end
  end
end
