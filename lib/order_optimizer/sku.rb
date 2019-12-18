class OrderOptimizer
  class Sku
    attr_reader :id, :quantity, :price_per_unit, :price_per_sku, :min_quantity

    def initialize(id, quantity:, price_per_sku: nil, price_per_unit: nil, min_quantity: nil)
      @id = id
      @quantity = quantity
      @min_quantity = min_quantity

      @price_per_unit = BigDecimal(price_per_unit, 2) if price_per_unit
      @price_per_sku  = BigDecimal(price_per_sku,  2) if price_per_sku

      unless price_per_unit || price_per_sku
        raise ':price_per_sku or :price_per_unit must be set'
      end

      @price_per_unit ||= price_per_sku.to_f / quantity
      @price_per_sku  ||= quantity * price_per_unit
    end
  end
end
