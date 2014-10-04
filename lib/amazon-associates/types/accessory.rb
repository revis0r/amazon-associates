module Amazon
  module Associates
    class Accessory < ApiResult
      xml_reader :asin, :from => 'ASIN'
      xml_reader :title, :from => "Title"
    end
  end
end