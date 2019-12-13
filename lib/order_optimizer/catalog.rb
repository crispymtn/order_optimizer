require 'order_optimizer/sku'

class OrderOptimizer
  class Catalog
    def initialize(skus)
      @skus = skus.map { |id, values| Sku.new(id, **values) }.sort_by(&:price_per_unit)
    end

    def skus
      @skus.dup
    end
  end
end
