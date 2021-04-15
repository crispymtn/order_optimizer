require 'bigdecimal'

require 'order_optimizer/catalog'
require 'order_optimizer/order'
require 'order_optimizer/version'

class OrderOptimizer
  def initialize(skus)
    @catalog = OrderOptimizer::Catalog.new(skus)
  end

  def cheapest_order(required_qty:)
    find_possible_orders(skus: @catalog.skus, required_qty: required_qty).min_by(&:total) ||
      OrderOptimizer::Order.new(required_qty: required_qty)
  end

  def cheapest_exact_order(required_qty:)
    find_possible_orders(skus: @catalog.skus, required_qty: required_qty).select(&:exact?).min_by(&:total) ||
      OrderOptimizer::Order.new(required_qty: required_qty)
  end

  def possible_orders(required_qty:)
    find_possible_orders(skus: @catalog.skus, required_qty: required_qty).sort_by(&:total)
  end

  private

  def find_possible_orders(required_qty:, skus:)
    return [] if required_qty < 1 || skus.empty?

    orders = []

    skus.each do |sku|
      orders.reject(&:complete?).each do |order|
        count, remainder, skip_increase = count_and_remainder_for_sku(order.missing_qty, sku)

        orders << order.dup.add(sku, count: count) unless count.zero?
        orders << order.dup.add(sku, count: count + 1) unless remainder.zero? || skip_increase
      end

      count, remainder, skip_increase = count_and_remainder_for_sku(required_qty, sku)

      unless count.zero?
        orders << OrderOptimizer::Order.new(required_qty: required_qty).add(sku, count: count)
      end

      unless remainder.zero? || skip_increase
        orders << OrderOptimizer::Order.new(required_qty: required_qty).add(sku, count: count + 1)
      end
    end

    orders.select(&:complete?)
  end

  def count_and_remainder_for_sku(quantity, sku)
    count, remainder = quantity.divmod(sku.quantity)

    if sku.max_quantity && count * sku.quantity > sku.max_quantity
      new_count = (sku.max_quantity / sku.quantity).ceil
      remainder = (count - new_count) * sku.quantity

      [new_count, [remainder, 0].max, true]
    elsif sku.min_quantity && count * sku.quantity < sku.min_quantity
      new_count = (sku.min_quantity / sku.quantity).ceil
      remainder -= (new_count - count) * sku.quantity

      [new_count, [remainder, 0].max, false]
    else
      [count, remainder, false]
    end
  end
end
