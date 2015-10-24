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
    @rules.each{ |rule| rule.update self }
    @total
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

module Inventory

  @@products = []

  class << self

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

# Test
describe 'Discounts' do

  fr = Product.new(code: 'FR', name: 'Fruit Tea', price: 3.11)
  sr = Product.new(code: 'SR', name: 'Strawberries', price: 5.00)
  cf = Product.new(code: 'CF', name: 'Coffe', price: 11.23)
  aj = Product.new(code: 'AJ', name: 'Apple Juice',  price: 7.25)
  Inventory.add(fr)
  Inventory.add(sr)
  Inventory.add(cf)
  Inventory.add(aj)

  rule1 = Rule::ByOneGetOneFree.new('FR')
  rule2 = Rule::DiscountIfOneByeMore.new(product_code: 'SR', min_count: 3, discount: 0.50)

  it 'valid example1' do
    co = Checkout.new(rule1, rule2)
    items = ['FR', 'SR', 'FR', 'FR', 'CF']
    items.each { |product_code| co.scan product_code }
    total_cost = co.total

    expect(total_cost).to eq 22.45
  end

  it 'valid example2' do
    co = Checkout.new(rule1, rule2)
    items = ['FR', 'FR']
    items.each { |product_code| co.scan product_code }
    total_cost = co.total

    expect(total_cost).to eq 3.11
  end

  it 'valid example3' do
    co = Checkout.new(rule1, rule2)
    items = ['SR', 'SR', 'FR', 'SR']
    items.each { |product_code| co.scan product_code }
    total_cost = co.total

    expect(total_cost).to eq 16.61
  end

end
