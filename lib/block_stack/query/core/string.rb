class String
  def to_query
    BlockStack::Query.new(self)
  end
end
