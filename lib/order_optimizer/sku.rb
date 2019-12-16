class OrderOptimizer
  class Sku
    attr_reader :id, :quantity, :price_per_unit, :price_per_sku, :min_quantity

    def initialize(id, quantity:, price_per_unit:, min_quantity: nil)
      @id = id
      @quantity = quantity
      @price_per_unit = BigDecimal(price_per_unit, 2)
      @price_per_sku = quantity * price_per_unit
      @min_quantity = min_quantity
    end

    private

    def set_min_quantity(min_qty)
      return unless min_qty

      if min_quantity.modulo(quantity).zero?
        @min_quantity = min_qty
      else
        raise ':min_quantity must be a multiple of :quantity'
      end
    end
  end
end
