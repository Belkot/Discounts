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
