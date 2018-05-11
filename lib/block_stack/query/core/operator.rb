module BlockStack
  class Query
    class Operator
      include BBLib::Effortless
      include BBLib::Prototype

      attr_str :primary, required: true, singleton: true
      attr_ary_of [String, Regexp], :alternatives, singleton: true
      attr_hash :localizations, singleton: true

      def self.find(expression)
        descendants.each do |operator|
          parts = operator.parse(expression)
          return parts if parts
        end
        nil
      end

      # Runs this operator by comparing the value to the expression. This should
      # be overriden in subclasses.
      def self.execute(value, expression)
        value == expression
      end

      # Returns the localized wording for this operator if a translation is
      # available.
      def self.local(language = Query.local)
        raise ArgumentError, "No localization available in #{language} for #{self}" unless localizations[language]
        localizations[language]
      end

      # Creates a worded version of this operator with a given value and expression
      # in the requested language (if it is available).
      def self.to_local(value, expression, language = Query.local)
        BBLib.pattern_render(local(language), serialize.merge(value: value, expression: expression))
      end

      # Returns true if the operator or any aliases do exist within the provided
      # query String.
      def self.match?(str)
        parse(str).size > 1
      end

      # Attempts to split the str (query) using this operator or any of its
      # aliases. If a match is found an array is returned where the first
      # element is the attribute and the second is the expression.
      # If no match is found nil is returned.
      def self.parse(str)
        ([primary] + alternatives).each do |expression|
          expression = " #{expression} " unless expression.is_a?(Regexp)
          parts = str.esplit(ENCAPSULATOR_EXPRESSIONS, expression, count: 2)
          next unless parts.size > 1
          return [self] + parts
        end
        # Return nil if nothing matched
        nil
      end

    end
  end

  require_all(File.expand_path('../../operators', __FILE__))
end
