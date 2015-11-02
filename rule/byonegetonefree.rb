module Rule

  class ByOneGetOneFree < Base

    def initialize(product_code)
      @product_code = product_code
    end

    def update(checkout)
      checkout.items.select { |product| product.code == @product_code }.
        map!.with_index { |product, index| product.price = 0.00 if index.odd? } #odd? becose start with 0

      super
    end

  end

end
