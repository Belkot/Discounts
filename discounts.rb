class Checkout

  attr_writer :total
  attr_reader :items #attr_accessor :items

  def initialize(*args)
    @rules = []
    args.each { |rule| @rules << rule }
    @items = []
  end

  def scan(product_code)
    product = Inventory.get(product_code).dup
    @items << product
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

class RuleBase

  def update(order)
    order.total = order.items.inject(0) { |sum, item| sum + item.price }
  end

end

class RuleByOneGetOneFree < RuleBase

  def initialize(product_code)
    @product_code = product_code
  end

  def update(order)
    order.items.select { |product| product.code == @product_code }.
      map!.with_index { |product, index| product.price = 0.00 if index.odd? } #odd? becose start with 0

    super
  end

end

class RuleDiscountIfOneByeMore < RuleBase

  def initialize(product_code:, min_count:, discount:)
    @product_code = product_code
    @min_count = min_count
    @discount = discount
  end

  def update(order)
    if order.items.count { |product| product.code == @product_code } >= @min_count
      order.items.select { |product| product.code == @product_code }.
        select { |product| product.price -= @discount }
    end

    super
  end

end

class RuleDiscountIfOneByeMoreCount < RuleDiscountIfOneByeMore

  def initialize(product_code:, min_count:, discount:)
    super
  end

  def update(order)
    if order.items.count { |product| product.price > 0 } >= @min_count
      order.items.reject { |product| product.price.zero? }.
        select { |product| product.code == @product_code }.
          map! { |product| product.price -= @discount }
    end

    super
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

  rule1 = RuleByOneGetOneFree.new('FR')
  rule2 = RuleDiscountIfOneByeMore.new(product_code: 'SR', min_count: 3, discount: 0.50)

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
