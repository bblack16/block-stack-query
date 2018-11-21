module BlockStack
  class Query
    OPERATORS = {
      equal:                 ['==', '=', / is (?!like|greater|less|not)/, 'equals', 'is equal to', 'equal to', /\:\s?(?!like|greater|less|not)?/],
      not_equal:             ['!=', '!:', / is not (?!like|greater|less|not)/, / isn\'?t /i, 'is not equal to', 'not equal to'],
      like:                  ['~', '~~', / is like /i, 'like'],
      match:                 ['=~', / matches /i],
      greater_than_or_equal: ['>=', 'gte', 'is greater than or equal to', 'greater than or equal to'],
      greater_than:          ['>', 'gt', 'is greater than', 'greater than'],
      less_than_or_equal:    ['<=', 'lte', 'is less than or equal to', 'less than or equal to'],
      less_than:             ['<', 'lt', 'is less than', 'less than'],
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
