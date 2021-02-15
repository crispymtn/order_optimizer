class OrderOptimizer
  class Sku
    attr_reader :id, :quantity, :price_per_unit, :price_per_sku, :min_quantity

    def initialize(id, quantity:, price_per_sku: nil, price_per_unit: nil, min_quantity: nil)
      @id = id
      @quantity = BigDecimal(quantity, 2)
      @min_quantity = BigDecimal(min_quantity, 2) if min_quantity

      unless price_per_unit || price_per_sku
        raise ':price_per_sku or :price_per_unit must be set'
      end

      @price_per_unit = BigDecimal(price_per_unit, 2) if price_per_unit
      @price_per_unit ||= BigDecimal(price_per_sku, 2) / quantity

      @price_per_sku = BigDecimal(price_per_sku,  2) if price_per_sku
      @price_per_sku ||= quantity * price_per_unit
    end
  end
end
