module BlockStack
  class Query
    module Util
      def self.to_range(value)
        case value
        when Array
          Range.new(*value[0..1])
        when String
          Range.new(*value.qsplit(/\.{2,3}/)[0..1], value.include?('...'))
        when Range
          value
        else
          [0..-1]
        end
      end
    end
  end
end
