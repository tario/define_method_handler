require "define_method_handler"


describe "define_method_handler" do
  
  it "self inside define_method_handler should be the chain object" do
    class CHAIN3_1
      define_method_handler(:foo) do
        self
      end
    end
    chain = CHAIN3_1.new
    chain.foo.should be == chain
  end
  
  it "should allow calling instance methods from method handler" do
    class CHAIN3_2
      def helper
        92
      end
      
      define_method_handler(:foo) do
        helper
      end
    end
    chain = CHAIN3_2.new
    chain.foo.should be == 92
  end
end
