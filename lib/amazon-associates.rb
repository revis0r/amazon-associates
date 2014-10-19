require 'rubygems'
require 'roxml'

%w(caching/filesystem_cache requests/cart requests/browse_node requests/item).each do |file|
  require File.join(File.dirname(__FILE__), 'amazon-associates', file)
end

module Amazon
  module Associates
    # Only we throw this
    class ConfigurationError < RuntimeError; end
    class BadLocale     < ArgumentError; end
    class MissingKey    < ArgumentError; end
    class MissingSecret < ArgumentError; end
    class MissingTag    < ArgumentError; end
    
    # The latest Amazon API version.
    CURRENT_API_VERSION = '2013-08-01'

    # A list of Amazon endpoints.
    HOSTS = {
      :ca => 'ecs.amazonaws.ca',
      :cn => 'webservices.amazon.cn',
      :de => 'ecs.amazonaws.de',
      :es => 'webservices.amazon.es',
      :fr => 'ecs.amazonaws.fr',
      :it => 'webservices.amazon.it',
      :jp => 'ecs.amazonaws.jp',
      :uk => 'ecs.amazonaws.co.uk',
      :us => 'ecs.amazonaws.com'
    }
    
    # Default search options
    @options = {}

    SORT_TYPES = {
      'All' => nil,
      'Apparel' => %w[relevancerank salesrank pricerank inverseprice -launch-date sale-flag],
      'Automotive' => %w[salesrank price -price titlerank -titlerank],
      'Baby' => %w[psrank salesrank price -price titlerank],
      'Beauty' => %w[pmrank salesrank price -price -launch-date sale-flag],
      'Books' => %w[relevancerank salesrank reviewrank pricerank inverse-pricerank daterank titlerank -titlerank],
      'Classical' => %w[psrank salesrank price -price titlerank -titlerank orig-rel-date],
      'DigitalMusic' => %w[songtitlerank uploaddaterank],
      'DVD' => %w[relevancerank salesrank price -price titlerank -video-release-date],
      'Electronics' => %w[pmrank salesrank reviewrank price -price titlerank],
      'GourmetFood' => %w[relevancerank salesrank pricerank inverseprice launch-date sale-flag],
      'HealthPersonalCare' => %w[pmrank salesrank pricerank inverseprice launch-date sale-flag],
      'Jewelry' => %w[pmrank salesrank pricerank inverseprice launch-date],
      'Kitchen' => %w[pmrank salesrank price -price titlerank -titlerank],
      'Magazines' => %w[subslot-salesrank reviewrank price -price daterank titlerank -titlerank],
      'Marketplace' => nil,
      'Merchants' => %w[relevancerank salesrank pricerank inverseprice launch-date sale-flag],
      'Miscellaneous' => %w[pmrank salesrank price -price titlerank -titlerank],
      'Music' => %w[psrank salesrank price -price titlerank -titlerank artistrank orig-rel-date release-date],
      'MusicalInstruments' => %w[pmrank salesrank price -price -launch-date sale-flag],
      'MusicTracks' => %w[titlerank -titlerank],
      'OfficeProducts' => %w[pmrank salesrank reviewrank price -price titlerank],
      'OutdoorLiving' => %w[psrank salesrank price -price titlerank -titlerank],
      'PCHardware' => %w[psrank salesrank price -price titlerank],
      'PetSupplies' => %w[+pmrank salesrank price -price titlerank -titlerank],
      'Photo' => %w[pmrank salesrank titlerank -titlerank],
      'Restaurants' => %w[relevancerank titlerank],
      'Software' => %w[pmrank salesrank titlerank price -price],
      'SportingGoods' => %w[relevancerank salesrank pricerank inverseprice launch-date sale-flag],
      'Tools' => %w[pmrank salesrank titlerank -titlerank price -price],
      'Toys' => %w[pmrank salesrank price -price titlerank -age-min],
      'VHS' => %w[relevancerank salesrank price -price titlerank -video-release-date],
      'Video' => %w[relevancerank salesrank price -price titlerank -video-release-date],
      'VideoGames' => %w[pmrank salesrank price -price titlerank],
      'Wireless' => %w[daterank pricerank invers-pricerank reviewrank salesrank titlerank -titlerank],
      'WirelessAccessories' => %w[psrank salesrank titlerank -titlerank]
    }.freeze

    SEARCH_INDEXES = (SORT_TYPES.keys + %w(Blended)).freeze
    DEFAULT_SEARCH_INDEX = 'Blended'

    class << self
      def configure(&proc)
        raise ArgumentError, "Block is required." unless block_given?
        yield @options
        case options[:caching_strategy]
        when :filesystem
          FilesystemCache.initialize_options(options)
        when nil
          nil
        else
          raise ConfigurationError, "Unrecognized caching_strategy"
        end
      end

      def options
        locale  = (@options[:country] || :us).to_sym
        @options[:host] = HOSTS[locale] or raise BadLocale
        raise MissingKey if @options[:key].blank?
        raise MissingSecret if @options[:secret].blank?
        raise MissingTag if @options[:tag].blank?
        @options
      end
    end

  protected
    def self.log(s)
      if defined?(Rails) && Rails.respond_to?(:logger)
        Rails.logger.error(s)
      elsif defined? RAILS_DEFAULT_LOGGER
        RAILS_DEFAULT_LOGGER.error(s)
      elsif defined? LOGGER
        LOGGER.error(s)
      else
        puts s if @debug
      end
    end
  end
end
