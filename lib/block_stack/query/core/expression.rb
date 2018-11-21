module BlockStack
  class Query
    class Expression < QueryComponent

      attr_str :original_expression, arg_at: 0
      attr_of [String, Symbol], :attribute, allow_nil: true
      attr_of Object, :expression
      attr_element_of OPERATORS, :operator, default: :equals
      attr_bool :inverse, default: false

      def to_s
        [(inverse ? 'NOT' : nil), attribute_to_s, OPERATORS[operator].first, expression_to_s].compact.join(' ')
      end

      def attribute_to_s
        string = attribute.to_s.include?(' ') ? "\"#{attribute}\"" : attribute.to_s
        attribute.is_a?(Symbol) ? ":#{string}" : string
      end

      def expression_to_s
        case expression
        when String
          "\"#{expression.gsub('"', '\\"')}\""
        when Regexp
          expression.inspect
        else
          expression.to_s
        end
      end

      def match?(obj)
        value = case obj
        when Hash
          obj.hpath(attribute).first
        else
          obj.respond_to?(attribute) && obj.method(attribute).arity == 0 ? obj.send(attribute) : nil
        end
        send(operator, value)
      end

      def equal(value)
        expression == value
      end

      def not_equal(value)
        expression != value
      end

      def greater_than(value)
        value > expression
      end

      def less_than(value)
        value < expression
      end

      def greater_than_or_equal(value)
        value >= expression
      end

      def less_than_or_equal(value)
        value <= expression
      end

      def match(value)
        expression =~ value
      end

      def like(value)
        exp = case expression
        when Regexp
          expression.inspect.scan(/^\/(.*)\//).flatten.first
        else
          expression.to_s
        end
        value =~ /#{Regexp.escape(exp).gsub('\\*', '.*')}/i
      end

      def contains(value)
        case value
        when Array, Hash
          value.include?(expression)
        when String
          value.include?(expression.to_s)
        else
          false # TODO Improve default handling
        end
      end

      def within(value)
        case expression
        when Array, Hash
          expression.include?(value)
        when String
          expression.include?(value.to_s)
        else
          false # TODO Improve default handling
        end
      end

      def between(value)
        (expression) === value
      end

      # TODO Add handling for regexp
      def start_with(value)
        value.to_s.start_with?(expression)
      end

      # TODO Add handling for regexp
      def end_with(value)
        value.to_s.end_with?(expression)
      end

      protected

      def analyze
        self.operator, self.attribute, self.expression = parse_string_expression
      end

      def parse_string_expression
        OPERATORS.each do |name, expressions|
          expressions.any? do |expression|
            exp = expression.is_a?(Regexp) ? expression : " #{expression} "
            parts = original_expression.esplit(ENCAPSULATOR_EXPRESSIONS, exp, count: 2)
            next unless parts.size > 1
            return [name, parse_attribute(parts.first), parse_value(parts.last)]
          end
        end
        # TODO Find a way to make the below work
        # [:like, '_any_', parse_value(original_expression)]
        raise InvalidExpression.new('No valid operator found within expression.', original_expression)
      end

      def parse_attribute(string)
        string = string.strip

        if string =~ /\s+(does|is)\s+not$/i
          self.inverse = true
          string = string.sub(/\s+(does|is)\s+not$/i, '')
        elsif string =~ /^not\s+/i
          self.inverse = true
          string = string.sub(/^not\s+/i, '')
        elsif string =~ /\s+not$/i
          self.inverse = true
          string = string.sub(/\s+not$/i, '')
        elsif string.start_with?('-')
          self.inverse = true
          string = string[1..-1]
        end

        if string.encap_by?('"')
          string.uncapsulate('"', limit: 1)
        elsif string.encap_by?("'")
          string.uncapsulate("'", limit: 1)
        elsif string.start_with?(':')
          parse_attribute(string[1..-1]).to_sym
        else
          string
        end
      end

      # TODO Add support for expressions such as now() for time
      # TODO Add date and time support for values. Not sure how yet...

      def parse_value(string)
        string = string.strip
        if string =~ /^\d+\.\d+$/
          string.to_f
        elsif string =~ /^\d+$/
          string.to_i
        elsif string.encap_by?('"')
          string.uncapsulate('"', limit: 1).gsub('\\"', '"')
        elsif string.encap_by?("'")
          string.uncapsulate("'", limit: 1).gsub("\\'", "'")
        elsif string =~ /^\/.*\/[mix]?+$/
          string.to_regex
        elsif string =~ /^true$/i
          true
        elsif string =~ /^false$/i
          false
        elsif string =~ /^(null|nil)$/i
          nil
        elsif string =~ /^\(?\d+(\.\d+)?\.{2,3}\d+(\.\d+)?\)?$/
          Range.new(*[string.split(/\.+/, 2).map(&:to_i), string =~ /\.{3}/].flatten)
        elsif string =~ /^\[.*\]$/
          string.uncapsulate('[', limit: 1).qsplit(',').map { |value| parse_value(value) }
        else
          string
        end
      end
    end
  end
end
