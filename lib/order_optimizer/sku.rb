class OrderOptimizer
  class Sku
    attr_reader :id, :quantity, :price_per_unit, :price_per_sku

    def initialize(id, quantity:, price_per_unit:)
      @id = id
      @quantity = quantity
      @price_per_unit = BigDecimal(price_per_unit, 2)
      @price_per_sku = quantity * price_per_unit
    end
  end
end
