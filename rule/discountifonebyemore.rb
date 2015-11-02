module Rule

  class DiscountIfOneByeMore < Base

    def initialize(product_code:, min_count:, discount:)
      @product_code = product_code
      @min_count = min_count
      @discount = discount
    end

    def update(checkout)
      if checkout.items.count { |product| product.code == @product_code } >= @min_count
        checkout.items.select { |product| product.code == @product_code }.
          select { |product| product.price -= @discount }
      end

      super
    end

  end

end
