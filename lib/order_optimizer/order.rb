class OrderOptimizer
  class Order
    attr_reader :quantity, :total, :skus

    def initialize(required_qty:)
      @quantity     = 0
      @required_qty = required_qty
      @total        = 0
      @skus         = {}
    end

    def add(sku, count: 1)
      @quantity += count * sku.quantity
      @total    += count * sku.price_per_sku
      @skus = skus.merge(sku.id => count) { |_identifier, current, plus| current + plus }
      self
    end

    def missing_qty
      [@required_qty - quantity, 0].max
    end

    def complete?
      missing_qty.zero?
    end
  end
end
