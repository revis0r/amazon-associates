module Amazon
  module Associates
    class BinParameter < ApiResult
      xml_name 'BinParameter'
      xml_reader :name, :from => 'Name'
      xml_reader :value, :from => 'Value'
    end
  end
end