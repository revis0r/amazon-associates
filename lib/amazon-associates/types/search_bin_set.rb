module Amazon
  module Associates
    class SearchBinSet < ApiResult
      xml_name 'SearchBinSet'
      xml_reader :narrow_by, :from => :attr, :required => true
      xml_reader :bins, :as => [Bin]
    end
  end
end