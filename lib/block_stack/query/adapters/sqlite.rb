module BlockStack
  class Query
    module Adapters
      class SQLite < Query::Adapter

        def self.classes
          ['Sequel::SQLite::Dataset']
        end

        def to_native
          query.expressions.map do |expression|
            _expression_to_s(expression)
          end.join(' AND ')
        end

        def execute
          dataset.where(Sequel.lit(to_native)).all
        rescue Sequel::DatabaseError => e
          []
        end

        def self.type
          :sqlite
        end

        protected

        def _expression_to_s(expression)
          case expression
          when RequiredGroup
            _required_to_sql(expression)
          when OptionalGroup
            _optional_to_sql(expression)
          when Expression
            _expression_to_sql(expression)
          end
        end

        def _optional_to_sql(group)
          group.expressions.map do |expression|
            _expression_to_s(expression)
          end.join(' OR ')
        end

        def _required_to_sql(group)
          group.expressions.map do |expression|
            _expression_to_s(expression)
          end.join(' AND ')
        end

        def _expression_to_sql(expression)
          self.send("_#{expression.operator}_to_s", expression)
        end

        def _value_to_s(value)
          case value
          when Integer, Float, TrueClass, FalseClass
            value.to_s
          when NilClass
            'null'
          else
            "'#{value}'"
          end
        end

        def _sql_wildcard(str)
          str.gsub('*', '%')
        end

        def _equal_to_s(exp)
          exp.operator == :equal && exp.inverse? ? _not_equal_to_s(exp) : "#{exp.attribute_to_s} == #{_value_to_s(exp.expression)}"
        end

        def _not_equal_to_s(exp)
          exp.operator == :not_equal && exp.inverse? ? _equal_to_s(exp) : "#{exp.attribute_to_s} != #{_value_to_s(exp.expression)}"
        end

        def _greater_than_to_s(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute_to_s} > #{_value_to_s(exp.expression)}"
        end

        def _less_than_to_s(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute_to_s} < #{_value_to_s(exp.expression)}"
        end

        def _greater_than_or_equal_to_s(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute_to_s} >= #{_value_to_s(exp.expression)}"
        end

        def _less_than_or_equal_to_s(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute_to_s} <= #{_value_to_s(exp.expression)}"
        end

        def _like_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} LIKE '#{_sql_wildcard(exp.expression)}'"
        end

        def _match_to_s(exp)
          expression = _sql_wildcard(exp.expression.inspect.scan(/(?<=^\/).*(?=\/)/).first).gsub('?', '%')
          expression = "%#{expression}" unless expression.start_with?('^')
          expression = "#{expression}%" unless expression.end_with?('^')
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} LIKE '#{expression}'"
        end

        def _contains_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} LIKE '%#{_sql_wildcard(exp.expression)}%'"
        end

        def _within_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} IN (#{[exp.expression].flatten(1).map { |v| "'#{v}'" }.join(', ')})"
        end

        def _start_with_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} LIKE '#{exp.expression}%'"
        end

        def _end_with_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} LIKE '%#{exp.expression}'"
        end

        def _between_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} BETWEEN #{exp.expression.begin} AND #{exp.expression.end}"
        end
      end
    end
  end
end
