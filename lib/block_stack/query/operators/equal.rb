module BlockStack
  class Query
    module Operators
      class Equal < Operator
        self.primary = '=='
        self.alternatives = ['=', / is /i]

        def self.execute(value, expression)
          value == expression
        end

      end
    end
  end
end
