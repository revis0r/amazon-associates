module Amazon
  module Associates
    class Bin < ApiResult
      xml_name 'Bin'
      xml_reader :bin_name
      xml_reader :bin_item_count
      xml_reader :bin_parameters, :as => [BinParameter]
    end
  end
end