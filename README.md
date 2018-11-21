# BlockStack Query

BlockStack Query is a powerful library and meta language for querying database structures that presents a single expression language that can easily be translated into many popular formats via adapters. Queries can be expressed very programmitcally or using plain English for clarity and ease of use for non-developers. The example below should be all you need to know.

```ruby
# You can create a query using plain english and most standard operators.
# You can also group expressions using parenthesis to make complex queries.
query = BlockStack::Query.new('name is Steve AND age < 70 OR name starts with Jo')

# Now we can convert the query into adapter specific query strings
puts query.to_sqlite
# => (name == 'Steve' AND age < 70) OR name LIKE 'Jo%'
puts query.to_mongo
# => {"$or":[{"name":"Steve","age":{"$lt":70}},{"name":{"$regex":"(?-mix:^Jo)","$options":"i"}}]}
puts query.to_elasticsearch
# => {"query":{"query_string":{"query":"(name:Steve AND age:<70) OR name:Jo*"}}}

# BlockStack::Query will automatically cast the query based on the adapter send to it
# and then execute the query and return the results.
require 'sequel'
DB = Sequel.sqlite('test.db')

query.execute(DB[:people])

# You can even use it to query arrays of Ruby objects or hashes!
ary = [{ name: 'Jackson', age: 5 }, { name: 'Nehra', age: 2 }, { name: 'Armani', age: 13 }]
p 'age is greater than 4'.to_query.execute(ary)
# => [{:name=>"Jackson", :age=>5}, {:name=>"Armani", :age=>13}]
```

BlockStack Query currently contains adapters for the following data structures:
- SQLite
- MySQL
- Postgre
- Mongo
- Elasticsearch
- Ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'block_stack_query'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install block_stack_query

## Usage

TODO: Coming eventually...

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/block_stack_query. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BlockStackQuery project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/block_stack_query/blob/master/CODE_OF_CONDUCT.md).
