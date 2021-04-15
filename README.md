# OrderOptimizer

The `OrderOptimizer` gem helps to optimize orders when the goods are offered in different pack sizes and in different discount levels.

Imagine a product can be ordered in different pack sizes and each pack size has a different price per unit. For example like this:

| Pack size | Price per Unit |
|-----------|----------------|
|    1000   |      3.90      |
|     100   |      4.00      |
|      10   |      6.00      |
|       1   |      9.00      |

In this example, it is quite obvious that it is cheaper buying one 10-pack instead of nine 1-packs when you need 9 units (because the 10-pack costs 60.00 but nine 1-packs would cost 81.00).

But what would be the cheapest combination when you need 946 units? Or 947?

The `OrderOptimizer` answers this kind of question in a performant way.

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
# Initialize the optimizer with a catalog
order_optimizer = OrderOptimizer.new(
  '1-pack' => { quantity: 1, price_per_unit: 9 },
  '10-pack' => { quantity: 10, price_per_unit: 6 },
  '100-pack' => { quantity: 100, price_per_unit: 4 },
  '1000-pack' => { quantity: 1000, price_per_unit: 3.9 }
)

# Pick the cheapers possible order for the required quantity
cheapest_order_for_946_units = order_optimizer.cheapest_order(required_qty: 946)
cheapest_order_for_946_units.quantity # =>  946
cheapest_order_for_946_units.total    # => 3894.00
cheapest_order_for_946_units.skus     # => { '100-pack' => 9, '10-pack' => 4, '1-pack' => 6 }

cheapest_order_for_947_units = order_optimizer.cheapest_order(required_qty: 947)
cheapest_order_for_947_units.quantity # => 1_000
cheapest_order_for_947_units.total    # => 3_900.00
cheapest_order_for_947_units.skus     # => { '1000-pack' => 1 }
```

You can also optimize your order for exact order amounts

```ruby
# Initialize the optimize with a catalog
order_optimizer = OrderOptimizer.new(
  '1-pack' => { quantity: 1, price_per_unit: 9 },
  '10-pack' => { quantity: 10, price_per_unit: 5 },
)

# Pick the cheapest order that includes the exact required quantity
cheapest_exact_order_for_58_units = order_optimizer.cheapest_exact_order(required_qty: 56)
cheapest_exact_order_for_58_units.quantity # => 58
cheapest_exact_order_for_58_units.total # => 322
cheapest_exact_order_for_58_units.skus # => { '10-pack' => 5, '1-pack' => 8 }
```

It is possible to define discount prices with a minimum quantity:

```ruby
order_optimizer = OrderOptimizer.new(
  '1-pack' => { quantity: 1, price_per_unit: 9 },
  '10-discount' => { quantity: 1, min_quantity: 10, price_per_unit: 8 },
  '20-pack' => { quantity: 20, price_per_unit: 7 }
)

order_optimizer.cheapest_order(required_qty: 8).skus
#=> { '1-pack' => 8 }

order_optimizer.cheapest_order(required_qty: 9).skus
#=> { '10-discount' => 10 }

order_optimizer.cheapest_order(required_qty: 17).skus
#=> { '10-discount' => 17 }

order_optimizer.cheapest_order(required_qty: 18).skus
#=> { '20-pack' => 1 }

order_optimizer.cheapest_order(required_qty: 21).skus
#=> { '20-pack' => 1, '1-pack' => 1 }

order_optimizer.cheapest_order(required_qty: 29).skus
#=> { '20-pack' => 1, '10-discount' => 10 }
```

It is also possible to define discount prices with a maximum quantity:
```ruby
order_optimizer = OrderOptimizer.new(
  '1-pack' => { quantity: 1, price_per_unit: 9 },
  '10-pack' => { quantity: 10, price_per_unit: 8, max_quantity: 20 },
)

order_optimizer.cheapest_order(required_qty: 30).skus
#=> { '10-pack' => 2, '1-pack' => 10 }
```

If you're just interested in all possible order combinations:

```ruby
# Initialize the optimize with a catalog
order_optimizer = OrderOptimizer.new(
  '1-pack' => { quantity: 1, price_per_unit: 9 },
  '10-pack' => { quantity: 10, price_per_unit: 5 },
)

order_optimizer.possible_orders(required_qty: 11).size
#=> 3
order_optimizer.possible_orders(required_qty: 10).map(&:skus)
#=> [{"10-pack"=>1, "1-pack"=>1}, {"1-pack"=>11}, {"10-pack"=>2}]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/zaikio/order_optimizer. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

- Make your changes and submit a pull request for them
- Make sure to update `CHANGELOG.md`

To release a new version of the gem:
- Update the version in `lib/order_optimizer/version.rb`
- Update `CHANGELOG.md` to include the new version and its release date
- Commit and push your changes
- Create a [new release on GitHub](https://github.com/zaikio/order_optimizer/releases/new)
- CircleCI will build the Gem package and push it Rubygems for you

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OrderOptimizer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/zaikio/order_optimizer/blob/master/CODE_OF_CONDUCT.md).
