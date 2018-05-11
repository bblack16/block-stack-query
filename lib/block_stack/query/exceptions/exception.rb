module BlockStack
  # Provides a base class for all other custom exception classes in Queriosity
  class QueryException < BlockStack::Exception; end
end

require_relative 'invalid_expression'
