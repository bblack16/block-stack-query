module BlockStack
  class Query
    class Adapter
      include BBLib::Effortless
      include BBLib::TypeInit

      attr_of Query, :query, required: true, arg_at: 0
      attr_of Object, :dataset, arg_at: 1

      # The string representations of all classes this adapter should be used for
      # When queries are executed against an object who's class is listed in this
      # method, this adapter will automatically be picked.
      def self.classes
        # Example: ['Hash', 'Array', 'Sequel::Database::SQLite']
        []
      end

      # TODO Add "to_<adapter>" to base query class
      def self.adapter_method
        type
      end

      def self.adapter_for(klass)
        klass = klass.class unless klass.is_a?(Class) || klass.is_a?(String)
        descendants.find do |adapter|
          adapter.classes.include?(klass.to_s)
        end || Adapters::Ruby
      end

      # Runs the current query against the current dataset.
      # The implementation will depend on the adapter.
      # This should always return an array.
      def execute
        []
      end

      # Generates the native query for the adapter. This could, for example,
      # be the SQL syntax for a SQLite adapter. For some adapters there may
      # not be a native syntax so the default method can be left as is.
      def to_native
        query.to_s
      end
    end
  end

  require_all(File.expand_path('../../adapters', __FILE__))
end
