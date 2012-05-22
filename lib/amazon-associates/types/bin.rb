module Amazon
  module Associates
    class Bin < ApiResult
      xml_name 'Bin'
      xml_reader :bin_name
      xml_reader :bin_item_count
      xml_reader :param_name, :from => 'Name', :in => 'xmlns:BinParameter'
      xml_reader :param_value, :from => 'Value', :in => 'xmlns:BinParameter'
    end
  end
end