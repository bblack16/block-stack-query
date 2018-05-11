module BlockStack
  class InvalidExpression < QueryException

    attr_reader :expression

    def initialize(message, expression)
      @expression = expression.to_s
      super(message)
    end

  end
end
