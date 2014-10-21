module Amazon
  module Associates
    class ImageSet < ApiResult
      xml_reader :category, :from => :attr, :required => true
      xml_reader :small, :as => Image, :from => 'SmallImage'
      xml_reader :medium, :as => Image, :from => 'MediumImage'
      xml_reader :large, :as => Image, :from => 'LargeImage'
      xml_reader :swatch, :as => Image, :from => 'SwatchImage'
      xml_reader :hi_res_image, :as => Image, :from => 'HiResImage'

      def largest_image_url
        self.send([:hi_res_image, :large, :medium, :small, :swatch].find{|f| self.try(f) }).url
      end
    end
  end
end