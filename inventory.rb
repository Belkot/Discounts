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

  require "./inventory/product.rb"

end
