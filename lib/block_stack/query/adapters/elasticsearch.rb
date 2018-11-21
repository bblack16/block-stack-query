require 'json'

module BlockStack
  class Query
    module Adapters
      class Elasticsearch < Query::Adapter

        def self.classes
          ['Elasticsearch::Client', 'Elasticsearch::Transport::Client', 'Elasticsearch::Dataset']
        end

        def to_native
          to_query_dsl.to_json
        end

        def to_query_dsl
          {
            query: {
              query_string: {
                query: query.expressions.map do |expression|
                  _to_query_dsl(expression).uncapsulate('(', limit: 1)
                end.join(' AND ')
              }
            }
          }
        end

        def execute
          case dataset.class.to_s
          when 'Elasticsearch::Dataset'
            dataset.search(to_query_dsl).keys_to_sym.hpath('hits.hits.[0..-1]').map do |res|
              res[:_source].merge(res.only(:_id, :_type, :_index))
            end
          else
            dataset.search(body: to_query_dsl).keys_to_sym.hpath('hits.hits.[0..-1]._source')
          end
        end

        protected

        def _to_query_dsl(expression)
          case expression
          when RequiredGroup
            _required_to_query_dsl(expression)
          when OptionalGroup
            _optional_to_query_dsl(expression)
          when Expression
            _expression_to_query_dsl(expression)
          end
        end

        def _optional_to_query_dsl(group)
          group.expressions.map do |expression|
            _to_query_dsl(expression)
          end.join(' OR ').encapsulate('(')
        end

        def _required_to_query_dsl(group)
          group.expressions.map do |expression|
            _to_query_dsl(expression)
          end.join(' AND ').encapsulate('(')
        end

        def _expression_to_query_dsl(expression)
          self.send("_#{expression.operator}_to_query_dsl", expression)
        end

        def _value_to_query_dsl(value)
          case value
          when Integer, Float, TrueClass, FalseClass
            value
          when Regexp
            value.inspect
          when Range
            "[#{value.first} TO #{value.last}#{value.exclude_end? ? '}' : ']'}"
          when Array
            "(#{value.map { |v| _value_to_query_dsl(v) }.join(', ')})"
          else
            value.to_s.include?(' ') ? "\"#{value}\"" : value.to_s
          end
        end

        def _equal_to_query_dsl(exp)
          return _not_equal_to_query_dsl(exp) if exp.operator == :equal && exp.inverse
          "#{exp.attribute}:#{_value_to_query_dsl(exp.expression)}"
        end

        def _not_equal_to_query_dsl(exp)
          return _equal_to_query_dsl(exp) if exp.operator == :not_equal && exp.inverse
          "NOT #{exp.attribute}:#{_value_to_query_dsl(exp.expression)}"
        end

        def _greater_than_to_query_dsl(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute}:>#{_value_to_query_dsl(exp.expression)}"
        end

        def _less_than_to_query_dsl(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute}:<#{_value_to_query_dsl(exp.expression)}"
        end

        def _greater_than_or_equal_to_query_dsl(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute}:>=#{_value_to_query_dsl(exp.expression)}"
        end

        def _less_than_or_equal_to_query_dsl(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute}:<=#{_value_to_query_dsl(exp.expression)}"
        end

        def _like_to_query_dsl(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute}:#{_value_to_query_dsl(exp.expression)}"
        end

        def _match_to_query_dsl(exp)
          expression = exp.expression.is_a?(Regexp) ? exp : /#{exp}/
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute}:#{_value_to_query_dsl(expression)}"
        end

        def _contains_to_query_dsl(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute}:#{_value_to_query_dsl("*#{exp.expression}*")}"
        end

        def _within_to_query_dsl(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute}:#{_value_to_query_dsl([exp.expression].flatten(1))}"
        end

        def _start_with_to_query_dsl(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute}:#{_value_to_query_dsl("#{exp.expression}*")}"
        end

        def _end_with_to_query_dsl(exp)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute}:#{_value_to_query_dsl("*#{exp.expression}")}"
        end

        # TODO Improve how ranges of dates work
        def _between_to_query_dsl(exp)
          expression = Query::Util.to_range(exp.expression)
          "#{exp.inverse? ? 'NOT ' : nil}#{exp.attribute}:#{_value_to_query_dsl(expression)}"
        end
      end
    end
  end
end
