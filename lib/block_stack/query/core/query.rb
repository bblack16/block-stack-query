require_relative 'constants'
require_relative 'query_component'
require_relative 'group_component'
require_relative 'expression'
require_relative 'required_group'
require_relative 'optional_group'
require_relative 'string'

module BlockStack
  # Query is the base class for BlockStack::Query and provides the parsing of
  # the BlockStack::Query DSL. Query objects can be passed to an adapter (e.g. SQLite)
  # to be executed.
  class Query
    include BBLib::Effortless

    attr_str :original_expression, arg_at: 0, required: true, aliases: [:expression, :query], pre_proc: :analyze_query
    attr_ary_of QueryComponent, :expressions

    after :original_expression=, :analyze

    # TODO Incorporate or delete this code
    # DEFAULT_LOCALE = :english
    #
    # def self.locale
    #   @locale ||= DEFAULT_LOCALE
    # end
    #
    # def self.locale=(language)
    #   require_relative "../localization/#{language}"
    #   @locale = language.to_sym
    # end
    #
    # self.locale = DEFAULT_LOCALE

    def ==(obj)
      return to_s == obj.to_s if obj.is_a?(Query)
      super
    end

    def self.execute(query, dataset)
      query = Query.new(original_expression: query) unless query.is_a?(Query)
      query.execute(dataset)
    end

    def self.adapter(query, dataset)
      query = Query.new(query) unless query.is_a?(Query)
      query.adapter(dataset)
    end

    def to_s
      expressions.map(&:to_s).join(' AND' )
    end

    def adapter(dataset)
      Adapter.adapter_for(dataset).new(query: self, dataset: dataset)
    end

    def execute(dataset)
      adapter(dataset).execute
    end

    def match?(object)
      expressions.all? do |expression|
        expression.match?(object)
      end
    end

    def matches?(objects)
      [objects].flatten(1).find_all do |object|
        match?(object)
      end
    end

    protected

    def analyze
      self.expressions = Query.parse_optionals(expression)
    end

    def analyze_query(query)
      case query
      when Hash
        query.map do |key, value|
          operator = case value
          when Regexp
            '=~'
          when Range
            '><'
          when Array
            'IN'
          else
            '=='
          end
          "#{key} #{operator} #{value.inspect}"
        end.join(' AND ')
      else
        query
      end
    end

    def self.parse_optionals(query, first_pass = true)
      split = BlockStack.safe_uncapsulate(query).esplit(ENCAPSULATOR_EXPRESSIONS, *OR_EXPRESSION_DIVIDERS).map(&:strip)
      if split.size == 1
        first_pass ? parse_requirements(split.first, false) : Expression.new(split.first)
      else
        OptionalGroup.new(split)
      end
    end

    def self.parse_requirements(query, first_pass = true)
      split = BlockStack.safe_uncapsulate(query).esplit(ENCAPSULATOR_EXPRESSIONS, *AND_EXPRESSION_DIVIDERS).map(&:strip)
      if split.size == 1
        first_pass ? parse_optionals(split.first, false) : Expression.new(split.first)
      else
        RequiredGroup.new(split)
      end
    end

    def method_missing(method, *args, &block)
      if adapter = Adapter.descendants.find { |a| "to_#{a.adapter_method}".to_sym == method }
        to_method = "to_#{adapter.adapter_method}".to_sym
        self.class.send(:define_method, to_method) do
          adapter.new(query: self).to_native
        end
        send(to_method)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      Adapter.descendants.any? { |a| "to_#{a.adapter_method}".to_sym == method } || super
    end

  end
end
