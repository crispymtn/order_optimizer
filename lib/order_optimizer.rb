require 'bigdecimal'

require "order_optimizer/catalog"
require "order_optimizer/order"
require "order_optimizer/version"

class OrderOptimizer
  def initialize(skus)
    @catalog = OrderOptimizer::Catalog.new(skus)
  end

  def cheapest_order(required_qty:)
    orders =
      possible_orders(skus: @catalog.skus_without_min_quantities, required_qty: required_qty) +
      possible_orders(skus: @catalog.skus_with_min_quantities, required_qty: required_qty) +
      possible_orders(skus: @catalog.skus, required_qty: required_qty)

    orders.min_by(&:total) || OrderOptimizer::Order.new
  end

  private

  def possible_orders(required_qty:, skus:)
    [].tap do |orders|
      order = OrderOptimizer::Order.new

      while required_qty.positive? && (sku = skus.shift)
        count, remainder = (required_qty - order.quantity).divmod(sku.quantity)
        count, remainder = adjustment_for_skus_with_min_quantity(sku, count, remainder)

        order.add(sku, count: count) unless count.zero?

        orders << (remainder.positive? ? order.dup.add(sku) : order.dup)

        order = OrderOptimizer::Order.new if sku.min_quantity
      end
    end
  end

  def adjustment_for_skus_with_min_quantity(sku, count, remainder)
    units = count * sku.quantity

    return count, remainder if sku.min_quantity.nil? || units >= sku.min_quantity

    delta = ((sku.min_quantity - units).to_f / sku.quantity).ceil
    [count + delta, remainder - (delta * sku.quantity)]
  end
end
