%w{errors extensions/core types/api_result  types/accessory types/variations
   types/error types/bin_parameter types/bin types/search_bin_set types/customer_review types/editorial_review types/ordinal types/listmania_list types/browse_node types/measurement types/image types/image_set types/price types/offer types/item types/requests types/cart
   responses/response responses/item_search_response responses/item_lookup_response responses/similarity_lookup_response responses/browse_node_lookup_response responses/cart_responses }.each do |file|
  require File.join(File.dirname(__FILE__), file)
end

require 'net/http'
require 'cgi'
require 'base64'

module Amazon
  module Associates
    def self.request(actions, &block)
      actions.each_pair do |action, main_arg|
        meta_def(action) do |*args|
          opts = args.extract_options!
          opts[main_arg] = args.first unless args.empty?
          opts[:operation] = action.to_s.camelize

          opts = yield opts if block_given?
          send_request(opts)
        end
      end
    end

  private
    # Generic send request to ECS REST service. You have to specify the :operation parameter.
    def self.send_request(opts)
      opts.to_options!
      # opts.reverse_merge! options.except(:caching_options, :caching_strategy)
      # if opts[:aWS_access_key_id].blank?
      #   raise ArgumentError, "amazon-associates requires the :aws_access_key_id option"
      # end
      log_body = opts.delete(:log)

      request_url = prepare_url(opts)
      response = nil
      log "Request URL: #{request_url}"
      
      if cache_it = cacheable?(opts[:operation])
        FilesystemCache.sweep

        response = FilesystemCache.get(opts.to_s)
      end

      unless response
        log "Not cached"
        response = Net::HTTP.get_response(request_url)
        unless response.kind_of? Net::HTTPSuccess
          raise RequestError, "HTTP Response: #{response.inspect}"
        end
        cache_response(opts.to_s, response) if cache_it
      end

      doc = ROXML::XML::Node.from(response.body)
      log(doc) if log_body
      eval(doc.name).from_xml(doc, request_url)
    end

    BASE_ARGS = [:key, :operation, :tag, :response_group]
    CART_ARGS = [:cart_id, :hMAC]
    ITEM_ARGS = (0..99).inject([:items]) do |all, i|
      all << :"Item.#{i}.ASIN"
      all << :"Item.#{i}.OfferListingId"
      all << :"Item.#{i}.CartItemId"
      all << :"Item.#{i}.Quantity"
      all
    end
    OTHER_ARGS = [
      :item_page, :item_id, :country, :type, :item_type,
      :browse_node_id, :actor, :artist, :audience_rating, :author,
      :availability, :brand, :browse_node, :city, :composer,
      :condition, :conductor, :director, :page, :keywords,
      :manufacturer, :maximum_price, :merchant_id,
      :minimum_price, :neighborhood, :orchestra,
      :postal_code, :power, :publisher, :search_index, :sort,
      :tag_page, :tags_per_page, :tag_sort, :text_stream,
      :title, :variation_page, :min_percentage_off
    ]
    VALID_ARGS = {
      'CartCreate' => ITEM_ARGS,
      'CartAdd' => ITEM_ARGS + CART_ARGS,
      'CartModify' => ITEM_ARGS + CART_ARGS,
      'CartGet' => CART_ARGS,
      'CartClear' => CART_ARGS
    }

    def self.valid_arguments(operation)
      BASE_ARGS + VALID_ARGS.fetch(operation, OTHER_ARGS)
    end

    HMAC_DIGEST = OpenSSL::Digest::Digest.new('sha256')

    def self.prepare_url(opts)
      opts = opts.to_hash.to_options!
      # raise opts.inspect if opts.has_key?(:cart)
      opts.assert_valid_keys(*valid_arguments(opts[:operation]))

      params = Hash[opts.map do |(k, v)|
        [k.to_s.camelize, v.is_a?(Array) ? v.join(',') : v.to_s]
      end]

      params.merge!(
        'Service' => 'AWSECommerceService',
        'Timestamp' => Time.now.gmtime.iso8601,
        'SignatureVersion' => '2',
        'SignatureMethod' => "HmacSHA256",
        'AWSAccessKeyId' => @options[:key],
        'AssociateTag'   => @options[:tag],
        'Version'        => CURRENT_API_VERSION
      )

      URI::HTTP.build :host  => @options[:host],
                      :path  => '/onca/xml',
                      :query => _query_string(params)
    end
    
    def self._escape(value)
      value.gsub(/([^a-zA-Z0-9_.~-]+)/) do
       '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
      end
    end

    def self._query_string(params)
      qs   = params.sort.map { |k, v| "#{k}=" + _escape(v) }.join('&')

      # Sign query string.
      req  = ['GET', @options[:host], '/onca/xml', qs]
      hmac = OpenSSL::HMAC.digest HMAC_DIGEST, @options[:secret], req.join("\n")
      sig  = _escape [hmac].pack('m').chomp

      "#{qs}&Signature=#{sig}"
    end

    def self.cacheable?(operation)
      caching_enabled? && !operation.starts_with?('Cart')
    end

    def self.caching_enabled?
      !options[:caching_strategy].blank?
    end

    def self.cache_response(request, response)
      FilesystemCache.cache(request, response)
    end
  end
end
