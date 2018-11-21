require 'block_stack/util' unless defined?(BlockStack::Util)

require_relative 'query/version'
require_relative 'query/exceptions/exception'
require_relative 'query/util/util'

# TODO Find a way to incorporate this or remove it
# require_relative 'query/core/operator'

require_relative 'query/core/query'
require_relative 'query/core/adapter'
