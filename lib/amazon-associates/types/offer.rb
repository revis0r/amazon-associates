module Amazon
  module Associates
    class Offer < ApiResult
      xml_reader :listing_id, :from => 'OfferListingId'
      xml_reader :price, :as => Price, :in => 'xmlns:OfferListing'
      xml_reader :amount_saved, :as => Price, :in => 'xmlns:OfferListing'
      xml_reader :percentage_saved, :in => 'xmlns:OfferListing'
      xml_reader :availability, :in => 'xmlns:OfferListing'
      xml_reader :condition, :in => 'xmlns:OfferAttributes'
      xml_reader :is_eligible_for_super_saver_shipping?, :in => 'xmlns:OfferListing'
    end
  end
end