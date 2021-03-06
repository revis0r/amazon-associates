require 'spec_helper'

module Amazon
  module Associates
    describe Item do
      before(:all) do
        @item = Amazon::Associates::item_lookup("0545010225").item
      end

      it "should equal anything with the same #asin" do
        asin = @item.asin
        @item.should == Struct.new(:asin).new(asin)
      end

      shared_examples_for "query for items" do
        it "should return a list of items" do
          @result.should have_at_least(10).items
          @result.each {|item| item.should be_an_instance_of(Item) }
        end
      end

      shared_examples_for "query for related items" do
        it_should_behave_like "query for items"
        it "should not include the item related to the result" do
          @result.should_not include(@item)
        end
      end

      describe ".similar" do
        before(:all) do
          @result = Item.similar(@item.asin)
        end
        it_should_behave_like "query for related items"
      end

      describe ".all" do
        before(:all) do
          @result = Item.all("search_index"=>"Blended", "keywords"=>"potter")
        end
        it_should_behave_like "query for items"

        it "should handle hashes with indifferent access" do
          Item.all(HashWithIndifferentAccess.new("search_index"=>"Blended", "keywords"=>"hello")).should_not == nil
        end
      end

      describe "#similar" do
        before(:all) do
          @result = @item.similar
        end
        it_should_behave_like "query for related items"
      end
    end
  end
end