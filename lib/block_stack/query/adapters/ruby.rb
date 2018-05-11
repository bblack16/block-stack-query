module BlockStack
  class Query
    module Adapters
      class Ruby < Query::Adapter

        # Classes here are not very important as the Ruby adapter is the default
        # if no other matching adapter is found.
        def self.classes
          ['Hash', 'Array']
        end

        def execute
          query.matches?(dataset)
        end

      end
    end
  end
end
