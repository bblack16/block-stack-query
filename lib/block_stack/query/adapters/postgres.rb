require_relative 'sqlite'

module BlockStack
  class Query
    module Adapters
      class Postgres < SQLite

        def self.classes
          ['Sequel::Postgres::Dataset']
        end

        def self.type
          :postgres
        end

        protected

        def _match_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} REGEXP '#{exp.expression.inspect.scan(/(?<=^\/).*(?=\/)/).first}'"
        end

        def _like_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} ILIKE '#{_sql_wildcard(exp.expression)}'"
        end

        def _match_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} REGEXP '#{exp.expression.inspect.scan(/(?<=^\/).*(?=\/)/).first}'"
        end

        def _contains_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} ILIKE '%#{_sql_wildcard(exp.expression)}%'"
        end

        def _start_with_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} ILIKE '#{exp.expression}%'"
        end

        def _end_with_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} ILIKE '%#{exp.expression}'"
        end
      end
    end
  end
end
