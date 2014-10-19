module Amazon
  module Associates
    # Ruby needs it..
    class Item < ApiResult
    end
    class Variations < ApiResult
      xml_reader :dimensions, :as => [], :in => 'xmlns:VariationDimensions', :from => 'VariationDimension'
      xml_reader :items, :as => [Item]
    end
  end
end