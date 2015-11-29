module Amazon
  module Associates
    class ItemDimensions < ApiResult
      xml_reader :height, :as => Measurement
      xml_reader :length, :as => Measurement
      xml_reader :weight, :as => Measurement
      xml_reader :width, :as => Measurement

      def formatted_weight
        "#{self.weight.value} #{self.weight.units}"
      end

      def formatted_dimensions
        "#{self.length.value} x #{self.width.value} x #{self.height.value} #{self.length.units}"
      end
    end
  end
end