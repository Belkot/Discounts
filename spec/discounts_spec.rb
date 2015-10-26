require './discounts.rb'

describe 'Discounts' do

  fr = Inventory::Product.new(code: 'FR', name: 'Fruit Tea', price: 3.11)
  sr = Inventory::Product.new(code: 'SR', name: 'Strawberries', price: 5.00)
  cf = Inventory::Product.new(code: 'CF', name: 'Coffe', price: 11.23)
  aj = Inventory::Product.new(code: 'AJ', name: 'Apple Juice',  price: 7.25)
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
