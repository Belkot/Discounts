module Rule

  class Base

    def update(checkout)
      checkout.total = checkout.items.inject(0) { |sum, item| sum + item.price }
    end

  end

end
