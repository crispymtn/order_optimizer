require 'order_optimizer/sku'

class OrderOptimizer
  class Catalog
    def initialize(skus)
      @skus = skus.map { |id, values| Sku.new(id, **values) }.sort_by(&:price_per_unit)
    end

    def skus
      @skus.dup
    end

    def skus_without_min_quantities
      @skus.reject(&:min_quantity)
    end

    def skus_with_min_quantities
      @skus.select(&:min_quantity)
    end
  end
end
