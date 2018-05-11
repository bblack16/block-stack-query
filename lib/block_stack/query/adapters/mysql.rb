require_relative 'sqlite'

module BlockStack
  class Query
    module Adapters
      class MySQL < SQLite

        def self.classes
          ['Sequel::Mysql2::Dataset']
        end

        def self.type
          :mysql
        end

        protected

        def _match_to_s(exp)
          "#{exp.attribute_to_s}#{exp.inverse? ? ' NOT' : nil} REGEXP '#{exp.expression.inspect.scan(/(?<=^\/).*(?=\/)/).first}'"
        end
      end
    end
  end
end
