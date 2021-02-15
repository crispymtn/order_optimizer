# frozen_string_literal: true

require 'test_helper'

class OrderOptimizerTest < Minitest::Test
  def test_that_it_handles_empty_catalogs
    optimizer = OrderOptimizer.new({})

    order = optimizer.cheapest_order(required_qty: 20)
    assert_equal 0, order.quantity
    assert_equal 0, order.total
    assert_equal({}, order.skus)
  end

  def test_that_it_handles_zero_required_quantities
    optimizer = OrderOptimizer.new(
      'A' => { quantity: 1, price_per_unit: 9 }
    )

    order = optimizer.cheapest_order(required_qty: 0)
    assert_equal 0, order.quantity
    assert_equal 0, order.total
    assert_equal({}, order.skus)
  end

  def test_that_it_works_with_a_simple_catalog
    optimizer = OrderOptimizer.new(
      'SKU-1' => { quantity: 150, price_per_sku: 22 },
      'SKU-2' => { quantity: 550, price_per_sku: 60 }
    )

    order = optimizer.cheapest_order(required_qty: 150)
    assert_equal 150, order.quantity
    assert_equal 22, order.total
    assert_equal({ 'SKU-1' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 151)
    assert_equal 300, order.quantity
    assert_equal 44, order.total
    assert_equal({ 'SKU-1' => 2 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 450)
    assert_equal 550, order.quantity
    assert_equal 60, order.total
    assert_equal({ 'SKU-2' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 451)
    assert_equal 550, order.quantity
    assert_equal 60, order.total
    assert_equal({ 'SKU-2' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 550)
    assert_equal 550, order.quantity
    assert_equal 60, order.total
    assert_equal({ 'SKU-2' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 600)
    assert_equal 700, order.quantity
    assert_equal 82, order.total
    assert_equal({ 'SKU-1' => 1, 'SKU-2' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 1400)
    assert_equal 1400, order.quantity
    assert_equal 164, order.total
    assert_equal({ 'SKU-1' => 2, 'SKU-2' => 2 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 1500)
    assert_equal 1650, order.quantity
    assert_equal 180, order.total
    assert_equal({ 'SKU-2' => 3 }, order.skus)
  end

  def test_that_it_works_with_many_different_pack_sizes
    optimizer = OrderOptimizer.new(
      '1-pack' => { quantity: 1, price_per_unit: 9 },
      '10-pack' => { quantity: 10, price_per_unit: 6 },
      '100-pack' => { quantity: 100, price_per_unit: 4 },
      '1000-pack' => { quantity: 1000, price_per_unit: 3.9 }
    )

    order = optimizer.cheapest_order(required_qty: 1)
    assert_equal 1, order.quantity
    assert_equal 9, order.total
    assert_equal({ '1-pack' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 6)
    assert_equal 6, order.quantity
    assert_equal 54, order.total
    assert_equal({ '1-pack' => 6 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 7)
    assert_equal 10, order.quantity
    assert_equal 60, order.total
    assert_equal({ '10-pack' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 64)
    assert_equal 64, order.quantity
    assert_equal 396, order.total
    assert_equal({ '10-pack' => 6, '1-pack' => 4 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 65)
    assert_equal 100, order.quantity
    assert_equal 400, order.total
    assert_equal({ '100-pack' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 946)
    assert_equal 946, order.quantity
    assert_equal 3_894, order.total
    assert_equal({ '100-pack' => 9, '10-pack' => 4, '1-pack' => 6 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 947)
    assert_equal 1_000, order.quantity
    assert_equal 3_900, order.total
    assert_equal({ '1000-pack' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 1_000_000_000)
    assert_equal 1_000_000_000, order.quantity
    assert_equal 3_900_000_000, order.total
    assert_equal({ '1000-pack' => 1_000_000 }, order.skus)
  end

  def test_that_it_works_with_discounts
    optimizer = OrderOptimizer.new(
      '250-pack' => { quantity: 250, price_per_unit: 10 },
      '990-discount' => { quantity: 250, price_per_unit: 9, min_quantity: 990 },
      '1000-pack' => { quantity: 1000, price_per_unit: 8.8 }
    )

    order = optimizer.cheapest_order(required_qty: 99)
    assert_equal 250, order.quantity
    assert_equal 2500, order.total
    assert_equal({ '250-pack' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 250)
    assert_equal 250, order.quantity
    assert_equal 2500, order.total
    assert_equal({ '250-pack' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 1000)
    assert_equal 1000, order.quantity
    assert_equal 8800, order.total
    assert_equal({ '1000-pack' => 1 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 1100)
    assert_equal 1250, order.quantity
    assert_equal 11_250, order.total
    assert_equal({ '990-discount' => 5 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 1750)
    assert_equal 1750, order.quantity
    assert_equal 15_750, order.total
    assert_equal({ '990-discount' => 7 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 1800)
    assert_equal 2000, order.quantity
    assert_equal 17_600, order.total
    assert_equal({ '1000-pack' => 2 }, order.skus)

    order = optimizer.cheapest_order(required_qty: 2100)
    # In this case the following would be correct:
    #
    # assert_equal 2250, order.quantity
    # assert_equal 20050, order.total
    # assert_equal({ '1000-pack' => 1, '990-discount' => 5 }, order.skus)
    #
    # But we are fine with this semi-optimum solution to avoid having
    # to calculate even more intermediate results.
    assert_equal 2250, order.quantity
    assert_equal 20_100, order.total
    assert_equal({ '1000-pack' => 2, '250-pack' => 1 }, order.skus)
  end

  def test_that_it_works_with_exact_match
    optimizer = OrderOptimizer.new(
      '100-pack' => { quantity: 100, price_per_sku: 22 },
      '500-pack' => { quantity: 500, price_per_sku: 80 }
    )

    order = optimizer.cheapest_exact_order(required_qty: 600)
    assert_equal 600, order.quantity
    assert_equal 102, order.total
    assert_equal({ '500-pack' => 1, '100-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_empty_order_if_not_exact_match
    optimizer = OrderOptimizer.new(
      '500-pack' => { quantity: 500, price_per_sku: 80 }
    )

    order = optimizer.cheapest_exact_order(required_qty: 600)
    assert_equal 0, order.quantity
    assert_equal 0, order.total
    assert_equal({}, order.skus)
  end

  def test_that_it_works_with_exact_match_and_min_quantity
    optimizer = OrderOptimizer.new(
      '100-pack' => { quantity: 100, price_per_sku: 22 },
      '500-pack' => { quantity: 500, price_per_unit: 80, min_quantity: 1000 }
    )

    order = optimizer.cheapest_exact_order(required_qty: 600)
    assert_equal 600, order.quantity
    assert_equal 132, order.total
    assert_equal({ '100-pack' => 6 }, order.skus)
  end

  def test_that_it_works_with_exact_match_and_many_different_package_sizes
    optimizer = OrderOptimizer.new(
      '1-pack' => { quantity: 1, price_per_sku: 9 },
      '10-pack' => { quantity: 10, price_per_sku: 60 },
      '100-pack' => { quantity: 100, price_per_sku: 400 },
      '250-pack' => { quantity: 250, price_per_sku: 875 }
    )

    order = optimizer.cheapest_exact_order(required_qty: 946)
    assert_equal 946, order.quantity
    assert_equal 3619, order.total
    assert_equal({ '250-pack' => 3, '100-pack' => 1, '10-pack' => 9, '1-pack' => 6 }, order.skus)

    optimizer = OrderOptimizer.new(
      '1-pack' => { quantity: 1, price_per_sku: 8 },
      '10-pack' => { quantity: 10, price_per_sku: 85 },
      '25-pack' => { quantity: 25, price_per_sku: 195 }
    )

    order = optimizer.cheapest_exact_order(required_qty: 36)
    assert_equal 36, order.quantity
    assert_equal 283, order.total
    assert_equal({ '25-pack' => 1, '1-pack' => 11 }, order.skus)

    order = optimizer.cheapest_exact_order(required_qty: 12)
    assert_equal 12, order.quantity
    assert_equal 96, order.total
    assert_equal({ '1-pack' => 12 }, order.skus)
  end

  def test_that_it_can_return_all_possible_orders
    optimizer = OrderOptimizer.new(
      '1-pack' => { quantity: 1, price_per_unit: 9 },
      '10-pack' => { quantity: 10, price_per_unit: 5 },
    )

    orders = optimizer.possible_orders(required_qty: 11)
    assert_equal 3, orders.count

    optimizer = OrderOptimizer.new(
      '1-pack' => { quantity: 1, price_per_sku: 9 },
      '10-pack' => { quantity: 10, price_per_sku: 60 },
      '100-pack' => { quantity: 100, price_per_sku: 400 },
      '250-pack' => { quantity: 250, price_per_sku: 875 }
    )

    orders = optimizer.possible_orders(required_qty: 946)
    assert_equal 15, orders.count
  end

  def test_that_it_does_not_have_floating_point_issues
    optimizer = OrderOptimizer.new(
      '1-pack' => { quantity: BigDecimal("715.392"),
                    min_quantity: BigDecimal("715.392"),
                    price_per_unit: 1 },
    )
    order, = optimizer.possible_orders(required_qty: 1)
    assert_equal({ '1-pack' => 1 }, order.skus)

    optimizer = OrderOptimizer.new(
      '1-pack' => { quantity: 101,
                    min_quantity: 100,
                    price_per_unit: 1 },
    )
    order, = optimizer.possible_orders(required_qty: 1)
    assert_equal({ '1-pack' => 1 }, order.skus)
  end
end
