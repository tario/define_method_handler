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
end
