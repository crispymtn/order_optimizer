class OrderOptimizer
  class Order
    attr_reader :quantity, :total, :skus

    def initialize
      @quantity = 0
      @total    = 0
      @skus     = {}
    end

    def add(sku, count: 1)
      @quantity += count * sku.quantity
      @total    += count * sku.price_per_sku
      @skus     = skus.merge(sku.id => count) { |identifier, current, plus| current + plus }
      self
    end
  end
end
