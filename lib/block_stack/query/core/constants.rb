module BlockStack
  class Query
    OPERATORS = {
      equal:                 ['==', '=', / is (?!like|greater|less|not)/, 'equals', / (is\s)?equal to /i, /\:\s?(?!like|greater|less|not)?/],
      not_equal:             ['!=', '!:', / is not (?!like|greater|less|not)/, / isn\'?t /i, / (is\s)?not equal(\sto)? /i],
      like:                  ['~', '~~', / (is\s)?like /i],
      match:                 ['=~', / matches /i],
      greater_than_or_equal: ['>=', 'gte', / (is\s)?greater than or equal to /i],
      greater_than:          ['>', 'gt', / (is\s)?greater than /i],
      less_than_or_equal:    ['<=', 'lte', / (is\s)?less than or equal to /i],
      less_than:             ['<', 'lt', / (is\s)?less than /i],
      contains:              ['contains'],
      within:                ['in', 'within'],
      between:               ['>=<', 'between'],
      start_with:            ['^~', / starts? with /i, / begins? with /i],
      end_with:              ['$~', / ends? with /i]
    }.freeze

    OR_EXPRESSION_DIVIDERS = %w{or ||}.map { |e| / #{Regexp.escape(e)} /i }

    AND_EXPRESSION_DIVIDERS = ['and', '&&', '+', '&'].map { |e| / #{Regexp.escape(e)} /i }

    ENCAPSULATOR_EXPRESSIONS = { '(': ')', '"': '"', "'": "'" }.freeze
  end
end
