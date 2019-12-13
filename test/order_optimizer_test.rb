require "test_helper"

class OrderOptimizerTest < Minitest::Test
  def setup
    @order_optimizer = OrderOptimizer.new(
      '1-pack' => { quantity: 1, price_per_unit: 9 },
      '10-pack' => { quantity: 10, price_per_unit: 6 },
      '100-pack' => { quantity: 100, price_per_unit: 4 },
      '1000-pack' => { quantity: 1000, price_per_unit: 3.9 }
    )
  end

  def test_that_it_returns_the_expected_results_for_0_units
    order = @order_optimizer.cheapest_order(required_qty: 0)

    assert_equal 0, order.quantity
    assert_equal 0, order.total
    assert_equal({}, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_1_unit
    order = @order_optimizer.cheapest_order(required_qty: 1)

    assert_equal 1, order.quantity
    assert_equal 9, order.total
    assert_equal({ '1-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_6_units
    order = @order_optimizer.cheapest_order(required_qty: 6)

    assert_equal 6, order.quantity
    assert_equal 54, order.total
    assert_equal({ '1-pack' => 6 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_7_units
    order = @order_optimizer.cheapest_order(required_qty: 7)

    assert_equal 10, order.quantity
    assert_equal 60, order.total
    assert_equal({ '10-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_64_units
    order = @order_optimizer.cheapest_order(required_qty: 64)

    assert_equal 64, order.quantity
    assert_equal 396, order.total
    assert_equal({ '10-pack' => 6, '1-pack' => 4 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_65_units
    order = @order_optimizer.cheapest_order(required_qty: 65)

    assert_equal 100, order.quantity
    assert_equal 400, order.total
    assert_equal({ '100-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_946_units
    order = @order_optimizer.cheapest_order(required_qty: 946)

    assert_equal 946, order.quantity
    assert_equal 3_894, order.total
    assert_equal({ '100-pack' => 9, '10-pack' => 4, '1-pack' => 6 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_947_unit
    order = @order_optimizer.cheapest_order(required_qty: 947)

    assert_equal 1_000, order.quantity
    assert_equal 3_900, order.total
    assert_equal({ '1000-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_1_000_000_000_units
    order = @order_optimizer.cheapest_order(required_qty: 1_000_000_000)

    assert_equal 1_000_000_000, order.quantity
    assert_equal 3_900_000_000, order.total
    assert_equal({ '1000-pack' => 1_000_000 }, order.skus)
  end
end
