module Amazon
  module Associates
    class ItemDimensions < ApiResult
      xml_reader :height, :as => Integer, :from => 'Height'
      xml_reader :length, :as => Integer, :from => 'Length'
      xml_reader :weight, :as => Integer, :from => 'Weight'
      xml_reader :width, :as => Integer, :from => 'Width'

      def formatted_weight
        "#{self.weight.to_i / 100.0} pounds"
      end

      def formatted_dimensions
        "#{self.length.to_i / 100.0} x #{self.width.to_i / 100.0} x #{self.height.to_i / 100.0} inches"
      end
    end
  end
end