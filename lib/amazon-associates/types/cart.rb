require 'roxml'

module Amazon
  module Associates
    class Cart < ApiResult
      xml_reader :items, :as => [CartItem], :from => 'xmlns:CartItem', :in => 'xmlns:CartItems', :frozen => true
      xml_reader :purchase_url, :from => 'xmlns:PurchaseURL'
      xml_reader :id, :from => 'xmlns:CartId', :required => true
      xml_reader :hmac, :from => 'xmlns:HMAC', :required => true

      delegate :empty?, :include?, :to => :items

      def to_hash
        {:id => id,
         :hmac => hmac}
      end

      #  CartCreate
      # defaults:
      #   response_group: Cart
      #   merge_cart: false
      #   list_item_id: nil
      def self.create(items, args = nil)
        if items.is_a?(Array)
          items = items.inject({}) do |all, (item, count)|
            all[item] = count || 1
            all
          end
        end
        Amazon::Associates.cart_create(items, args).cart
      end

      #  CartGet
      def self.get(args)
        Amazon::Associates.cart_get(args).cart
      end

      def save
        @changes.each do |action, *args|
          cart = Amazon::Associates.send(action, *args).cart
          @items = cart.items
          @id = cart.id
          @hmac = cart.hmac
        end
        @changes.clear
        self
      end

      def changed?
        !@changes.empty?
      end

      def add(item, offer_id = nil, count = 1)
        raise ArgumentError, "item is nil" if item.nil?
        raise ArgumentError, "count isn't positive" if count <= 0

        if @items.include? item
          action = :cart_modify
          item = @items.find {|i| i == item } # we need the CartItemId for CartModify
          count += item.quantity
        else
          action = :cart_add
          if offer_id.present?
            item = {offer_listing_id: offer_id}
          end
        end
        # TODO: This could be much more sophisticated, collapsing operations and such
        @changes << [action, self, {:items => {item => count}}]
      end
      alias_method :<<, :add

      def change_quantity(cart_item_id, quantity)
        item = @items.find {|i| i.cart_item_id == cart_item_id }
        if item.present?
          @changes << [:cart_modify, self, {:items => {item => quantity}}]
        else
          false
        end
      end

      def clear
        @changes << [:cart_clear, self]
      end

      def quantity
        items.sum(&:quantity)
      end

      def ==(other)
        id == other.id
      end

    private
      def initialize
        @changes = []
      end
    end
  end
end