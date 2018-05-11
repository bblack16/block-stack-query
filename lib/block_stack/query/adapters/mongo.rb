require 'json'

module BlockStack
  class Query
    module Adapters
      class Mongo < Query::Adapter

        def self.classes
          ['Mongo::Collection']
        end

        def to_native
          to_mongo_query.to_json
        end

        def to_mongo_query
          array = query.expressions.map do |expression|
            _to_mongo(expression)
          end
          array.size == 1 ? array.first : array
        end

        def execute
          # TODO
        end

        protected

        def _to_mongo(expression)
          case expression
          when RequiredGroup
            _required_to_mongo(expression)
          when OptionalGroup
            _optional_to_mongo(expression)
          when Expression
            _expression_to_mongo(expression)
          end
        end

        def _optional_to_mongo(group)
          {
            '$or' =>
            group.expressions.map do |expression|
              _to_mongo(expression)
            end
          }
        end

        def _required_to_mongo(group)
          {}.tap do |hash|
            group.expressions.each do |expression|
              hash.merge!(_to_mongo(expression))
            end
          end
        end

        def _expression_to_mongo(expression)
          self.send("_#{expression.operator}_to_mongo", expression)
        end

        def _value_to_mongo(value)
          value
        end

        def _equal_to_mongo(exp)
          return _not_equal_to_mongo(exp) if exp.operator == :equal && exp.inverse
          { exp.attribute => exp.expression  }
        end

        def _not_equal_to_mongo(exp)
          return _equal_to_mongo(exp) if exp.operator == :not_equal && exp.inverse
          { exp.attribute => { '$ne' => exp.expression } }
        end

        def _greater_than_to_mongo(exp)
          { exp.attribute => { '$gt' => exp.expression } }
        end

        def _less_than_to_mongo(exp)
          { exp.attribute => { '$lt' => exp.expression } }
        end

        def _greater_than_or_equal_to_mongo(exp)
          { exp.attribute => { '$gte' => exp.expression } }
        end

        def _less_than_or_equal_to_mongo(exp)
          { exp.attribute => { '$lte' => exp.expression } }
        end

        def _like_to_mongo(exp)
          { exp.attribute => { '$regex' => /^#{Regexp.escape(exp.expression.to_s).gsub('*', '.*')}$/.inspect, '$options' => 'i' } }
        end

        def _match_to_mongo(exp)
          options = ''
          options = exp.inspect.split('/').last if exp.expression.is_a?(Regexp)
          { exp.attribute => { '$regex' => /#{Regexp.escape(exp.expression.to_s)}/, '$options' => options } }
        end

        def _contains_to_mongo(exp)
          { exp.attribute => { '$in' => [exp.expression].flatten(1) } }
        end

        def _within_to_mongo(exp)
          # TODO
        end

        def _start_with_to_mongo(exp)
          # TODO
        end

        def _end_with_to_mongo(exp)
          # TODO
        end

        def _between_to_mongo(exp)
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
