require "test_helper"

class OrderOptimizerTest < Minitest::Test
  def different_packs
    OrderOptimizer.new(
      '1-pack' => { quantity: 1, price_per_unit: 9 },
      '10-pack' => { quantity: 10, price_per_unit: 6 },
      '100-pack' => { quantity: 100, price_per_unit: 4 },
      '1000-pack' => { quantity: 1000, price_per_unit: 3.9 }
    )
  end

  def different_discounts
    OrderOptimizer.new(
      '1-pack' => { quantity: 1, price_per_unit: 9 },
      '10-discount' => { quantity: 1, price_per_unit: 8, min_quantity: 10 },
      '100-discount' => { quantity: 1, price_per_unit: 7, min_quantity: 100 }
    )
  end

  def mixed_pricing
    OrderOptimizer.new(
      '1-pack' => { quantity: 1, price_per_unit: 9 },
      '10-discount' => { quantity: 1, price_per_unit: 8, min_quantity: 10 },
      '20-pack' => { quantity: 20, price_per_unit: 7 }
    )
  end

  def test_that_it_returns_the_expected_results_for_0_units
    order = different_packs.cheapest_order(required_qty: 0)

    assert_equal 0, order.quantity
    assert_equal 0, order.total
    assert_equal({}, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_1_unit
    order = different_packs.cheapest_order(required_qty: 1)

    assert_equal 1, order.quantity
    assert_equal 9, order.total
    assert_equal({ '1-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_6_units
    order = different_packs.cheapest_order(required_qty: 6)

    assert_equal 6, order.quantity
    assert_equal 54, order.total
    assert_equal({ '1-pack' => 6 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_7_units
    order = different_packs.cheapest_order(required_qty: 7)

    assert_equal 10, order.quantity
    assert_equal 60, order.total
    assert_equal({ '10-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_64_units
    order = different_packs.cheapest_order(required_qty: 64)

    assert_equal 64, order.quantity
    assert_equal 396, order.total
    assert_equal({ '10-pack' => 6, '1-pack' => 4 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_65_units
    order = different_packs.cheapest_order(required_qty: 65)

    assert_equal 100, order.quantity
    assert_equal 400, order.total
    assert_equal({ '100-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_946_units
    order = different_packs.cheapest_order(required_qty: 946)

    assert_equal 946, order.quantity
    assert_equal 3_894, order.total
    assert_equal({ '100-pack' => 9, '10-pack' => 4, '1-pack' => 6 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_947_unit
    order = different_packs.cheapest_order(required_qty: 947)

    assert_equal 1_000, order.quantity
    assert_equal 3_900, order.total
    assert_equal({ '1000-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_expected_results_for_1_000_000_000_units
    order = different_packs.cheapest_order(required_qty: 1_000_000_000)

    assert_equal 1_000_000_000, order.quantity
    assert_equal 3_900_000_000, order.total
    assert_equal({ '1000-pack' => 1_000_000 }, order.skus)
  end

  def test_that_it_returns_the_expected_discount_for_1_unit
    order = different_discounts.cheapest_order(required_qty: 1)

    assert_equal 1, order.quantity
    assert_equal 9, order.total
    assert_equal({ '1-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_expected_discount_for_8_units
    order = different_discounts.cheapest_order(required_qty: 8)

    assert_equal 8, order.quantity
    assert_equal 72, order.total
    assert_equal({ '1-pack' => 8 }, order.skus)
  end

  def test_that_it_returns_the_expected_discount_for_9_units
    order = different_discounts.cheapest_order(required_qty: 9)

    assert_equal 10, order.quantity
    assert_equal 80, order.total
    assert_equal({ '10-discount' => 10 }, order.skus)
  end

  def test_that_it_returns_the_expected_discount_for_10_units
    order = different_discounts.cheapest_order(required_qty: 10)

    assert_equal 10, order.quantity
    assert_equal 80, order.total
    assert_equal({ '10-discount' => 10 }, order.skus)
  end

  def test_that_it_returns_the_expected_discount_for_11_units
    order = different_discounts.cheapest_order(required_qty: 11)

    assert_equal 11, order.quantity
    assert_equal 88, order.total
    assert_equal({ '10-discount' => 11 }, order.skus)
  end

  def test_that_it_returns_the_expected_discount_for_87_units
    order = different_discounts.cheapest_order(required_qty: 87)

    assert_equal 87, order.quantity
    assert_equal 696, order.total
    assert_equal({ '10-discount' => 87 }, order.skus)
  end

  def test_that_it_returns_the_expected_discount_for_88_units
    order = different_discounts.cheapest_order(required_qty: 88)

    assert_equal 100, order.quantity
    assert_equal 700, order.total
    assert_equal({ '100-discount' => 100 }, order.skus)
  end

  def test_that_it_returns_the_expected_discount_for_89_units
    order = different_discounts.cheapest_order(required_qty: 89)

    assert_equal 100, order.quantity
    assert_equal 700, order.total
    assert_equal({ '100-discount' => 100 }, order.skus)
  end

  def test_that_it_returns_the_expected_discount_for_100_units
    order = different_discounts.cheapest_order(required_qty: 100)

    assert_equal 100, order.quantity
    assert_equal 700, order.total
    assert_equal({ '100-discount' => 100 }, order.skus)
  end

  def test_that_it_returns_the_expected_discount_for_101_units
    order = different_discounts.cheapest_order(required_qty: 101)

    assert_equal 101, order.quantity
    assert_equal 707, order.total
    assert_equal({ '100-discount' => 101 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_1_unit
    order = mixed_pricing.cheapest_order(required_qty: 1)

    assert_equal 1, order.quantity
    assert_equal 9, order.total
    assert_equal({ '1-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_8_units
    order = mixed_pricing.cheapest_order(required_qty: 8)

    assert_equal 8, order.quantity
    assert_equal 72, order.total
    assert_equal({ '1-pack' => 8 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_9_units
    order = mixed_pricing.cheapest_order(required_qty: 9)

    assert_equal 10, order.quantity
    assert_equal 80, order.total
    assert_equal({ '10-discount' => 10 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_10_units
    order = mixed_pricing.cheapest_order(required_qty: 10)

    assert_equal 10, order.quantity
    assert_equal 80, order.total
    assert_equal({ '10-discount' => 10 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_11_units
    order = mixed_pricing.cheapest_order(required_qty: 11)

    assert_equal 11, order.quantity
    assert_equal 88, order.total
    assert_equal({ '10-discount' => 11 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_17_units
    order = mixed_pricing.cheapest_order(required_qty: 17)

    assert_equal 17, order.quantity
    assert_equal 136, order.total
    assert_equal({ '10-discount' => 17 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_18_units
    order = mixed_pricing.cheapest_order(required_qty: 18)

    assert_equal 20, order.quantity
    assert_equal 140, order.total
    assert_equal({ '20-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_20_units
    order = mixed_pricing.cheapest_order(required_qty: 20)

    assert_equal 20, order.quantity
    assert_equal 140, order.total
    assert_equal({ '20-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_21_units
    order = mixed_pricing.cheapest_order(required_qty: 21)

    assert_equal 21, order.quantity
    assert_equal 149, order.total
    assert_equal({ '20-pack' => 1, '1-pack' => 1 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_28_units
    order = mixed_pricing.cheapest_order(required_qty: 28)

    assert_equal 28, order.quantity
    assert_equal 212, order.total
    assert_equal({ '20-pack' => 1, '1-pack' => 8 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_29_units
    order = mixed_pricing.cheapest_order(required_qty: 29)

    assert_equal 30, order.quantity
    assert_equal 220, order.total
    assert_equal({ '20-pack' => 1, '10-discount' => 10 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_30_units
    order = mixed_pricing.cheapest_order(required_qty: 30)

    assert_equal 30, order.quantity
    assert_equal 220, order.total
    assert_equal({ '20-pack' => 1, '10-discount' => 10 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_37_units
    order = mixed_pricing.cheapest_order(required_qty: 37)

    assert_equal 37, order.quantity
    assert_equal 276, order.total
    assert_equal({ '20-pack' => 1, '10-discount' => 17 }, order.skus)
  end

  def test_that_it_returns_the_mixed_price_for_38_units
    order = mixed_pricing.cheapest_order(required_qty: 38)

    assert_equal 40, order.quantity
    assert_equal 280, order.total
    assert_equal({ '20-pack' => 2 }, order.skus)
  end
end
