class Checkout

  attr_writer :total
  attr_reader :items

  def initialize(*args)
    @rules = []
    args.each { |rule| @rules << rule }
    @items = []
  end

  def scan(product_code)
    product = Inventory.get(product_code)
    @items << product.dup if product
  end

  def total
    @rules.each { |rule| rule.update self }
    @total
  end

end


module Inventory

  @@products = []

  class << self

    def all
      @@products
    end

    def add(product)
      if @@products.count { |e| e.code == product.code}.zero?
        @@products << product.dup
      else
        remove(product.code)
        add(product)
      end
    end

    def get(code)
      @@products.select { |product| product.code == code}.first
    end

    def remove(code)
      @@products.delete_if { |product| product.code == code }
    end

  end

  class Product

    attr_reader :code, :name
    attr_accessor :price

    def initialize(code:, name:, price:)
      @code = code
      @name = name
      @price = price
    end

  end

end

module Rule

  class Base

    def update(checkout)
      checkout.total = checkout.items.inject(0) { |sum, item| sum + item.price }
    end

  end

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
