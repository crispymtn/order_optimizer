# OrderOptimizer

The `OrderOptimizer` gem helps to optimize orders if the goods are offered in different pack sizes and in different discount levels.

Imagine a product can be ordered in different pack sizes and each pack size has a different price per unit. For example like this:

| Pack size | Price per Unit |
|    1000   |      3.90      |
|     100   |      4.00      |
|      10   |      6.00      |
|       1   |      9.00      |

It is quite obvious that it is cheaper buying one 10-pack instead of nine 1-packs when you need 9 units (because the 10-pack costs 60.00 but 9 1-packs would cost 81.00). But what would be the cheapest combination when you need 946 units? Or 947?

The `OrderOptimizer` answers this kind of question in a performat way.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'order_optimizer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install order_optimizer

## Usage

```ruby
order_optimizer = OrderOptimizer.new(
  '1-pack' => { quantity: 1, price_per_unit: 9 },
  '10-pack' => { quantity: 10, price_per_unit: 6 },
  '100-pack' => { quantity: 100, price_per_unit: 4 },
  '1000-pack' => { quantity: 1000, price_per_unit: 3.9 }
)

cheapest_order_for_946_units = order_optimizer.cheapest_order(required_qty: 946)
cheapest_order_for_946_units.quantity # =>  946
cheapest_order_for_946_units.total    # => 3894.00
cheapest_order_for_946_units.skus     # => { '100-pack' => 9, '10-pack' => 4, '1-pack' => 6 }

cheapest_order_for_947_units = order_optimizer.cheapest_order(required_qty: 947)
cheapest_order_for_947_units.quantity # => 1_000
cheapest_order_for_947_units.total    # => 3_900.00
cheapest_order_for_947_units.skus     # => { '1000-pack' => 1 }
``

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/crispymtn/order_optimizer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OrderOptimizer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/crispymtn/order_optimizer/blob/master/CODE_OF_CONDUCT.md).
