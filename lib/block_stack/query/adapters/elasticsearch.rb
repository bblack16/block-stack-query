require 'json'

module BlockStack
  class Query
    module Adapters
      class Elasticsearch < Query::Adapter

        def self.classes
          ['Elasticsearch::Client', 'Elasticsearch::Transport::Client']
        end

        def to_native
          to_query_dsl.to_json
        end

        def to_query_dsl
          array = query.expressions.map do |expression|
            {
              query: {
                bool: _to_query_dsl(expression)
              }
            }
          end
          array.size == 1 ? array.first : array
        end

        # TODO Need to add dataset support to Elasticsearch gem
        def execute
          dataset.search(body: to_query_dsl).to_a
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
          { should: group.expressions.map { |exp| _to_query_dsl(exp) } }
        end

        def _required_to_query_dsl(group)
          { must: group.expressions.map { |exp| _to_query_dsl(exp) } }
        end

        def _expression_to_query_dsl(expression)
          self.send("_#{expression.operator}_to_query_dsl", expression)
        end

        def _value_to_query_dsl(value)
          value
        end

        def _equal_to_query_dsl(exp)
          return _not_equal_to_query_dsl(exp) if exp.operator == :equal && exp.inverse
          { match: { exp.attribute => exp.expression } }
        end

        def _not_equal_to_query_dsl(exp)
          return _equal_to_query_dsl(exp) if exp.operator == :not_equal && exp.inverse
          { exp.attribute => { '$ne' => exp.expression } }
        end

        def _greater_than_to_query_dsl(exp)
          { exp.attribute => { '$gt' => exp.expression } }
        end

        def _less_than_to_query_dsl(exp)
          { exp.attribute => { '$lt' => exp.expression } }
        end

        def _greater_than_or_equal_to_query_dsl(exp)
          { exp.attribute => { '$gte' => exp.expression } }
        end

        def _less_than_or_equal_to_query_dsl(exp)
          { exp.attribute => { '$lte' => exp.expression } }
        end

        def _like_to_query_dsl(exp)
          { exp.attribute => { '$regex' => /^#{Regexp.escape(exp.expression.to_s).gsub('*', '.*')}$/, '$options' => 'i' } }
        end

        def _match_to_query_dsl(exp)
          options = ''
          options = exp.inspect.split('/').last if exp.expression.is_a?(Regexp)
          { exp.attribute => { '$regex' => /#{Regexp.escape(exp.expression.to_s)}/, '$options' => options } }
        end

        def _contains_to_query_dsl(exp)
          { exp.attribute => { '$regex' => /#{Regexp.escape(exp.expression.to_s)}/, '$options' => 'i' } }
        end

        def _within_to_query_dsl(exp)
          { exp.attribute => { '$in' => [exp.expression].flatten(1) } }
        end

        def _start_with_to_query_dsl(exp)
          { exp.attribute => { '$regex' => /^#{Regexp.escape(exp.expression.to_s)}/, '$options' => 'i' } }
        end

        def _end_with_to_query_dsl(exp)
          { exp.attribute => { '$regex' => /#{Regexp.escape(exp.expression.to_s)}$/, '$options' => 'i' } }
        end

        def _between_to_query_dsl(exp)
          start, stop = case exp.expression
          when Range
            [exp.expression.start, exp.expression.end]
          else
            exp.expression
          end
          {
            exp.attribute => {
              '$lte' => start,
              '$gte' => stop
            }
          }
        end
      end
    end
  end
end
