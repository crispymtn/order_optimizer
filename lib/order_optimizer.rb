require 'bigdecimal'

require "order_optimizer/catalog"
require "order_optimizer/order"
require "order_optimizer/version"

class OrderOptimizer
  def initialize(skus)
    @catalog = OrderOptimizer::Catalog.new(skus)
  end

  def cheapest_order(required_qty:)
    possible_orders(required_qty: required_qty)
      .min_by(&:total)
  end

  private

  def possible_orders(required_qty:)
    [].tap do |orders|
      skus  = @catalog.skus
      order = OrderOptimizer::Order.new
      while sku = skus.shift
        count, remainder = (required_qty - order.quantity).divmod(sku.quantity)
        order.add(sku, count: count) unless count.zero?
        orders << (remainder.zero? ? order.dup : order.dup.add(sku))
      end
    end
  end
end
