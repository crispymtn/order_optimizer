require 'bigdecimal'

require 'order_optimizer/catalog'
require 'order_optimizer/order'
require 'order_optimizer/version'

class OrderOptimizer
  def initialize(skus)
    @catalog = OrderOptimizer::Catalog.new(skus)
  end

  def cheapest_order(required_qty:)
    possible_orders(skus: @catalog.skus, required_qty: required_qty)
      .min_by(&:total) || OrderOptimizer::Order.new(required_qty: required_qty)
  end

  private

  def possible_orders(required_qty:, skus:)
    return [] if required_qty < 1 || skus.empty?

    orders = []

    skus.each do |sku|
      orders.reject(&:complete?).each do |order|
        count, remainder = count_and_remainder_for_sku(order.missing_qty, sku)

        orders << order.dup.add(sku, count: count) unless count.zero?
        orders << order.dup.add(sku, count: count + 1) if remainder
      end

      count, remainder = count_and_remainder_for_sku(required_qty, sku)

      unless count.zero?
        orders << OrderOptimizer::Order.new(required_qty: required_qty).add(sku, count: count)
      end
      if remainder
        orders << OrderOptimizer::Order.new(required_qty: required_qty).add(sku, count: count + 1)
      end
    end

    orders.select(&:complete?)
  end

  def count_and_remainder_for_sku(quantity, sku)
    count, remainder = quantity.divmod(sku.quantity)

    if sku.min_quantity && count * sku.quantity < sku.min_quantity
      new_count = (sku.min_quantity.to_f / sku.quantity).ceil
      remainder -= (new_count - count) * sku.quantity
      [new_count, [remainder, 0].max]
    else
      [count, remainder]
    end
  end
end
