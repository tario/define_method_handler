require "define_method_handler"


describe "define_method_handler" do
  
  it "single method handler without condition should act as the a method" do
    class CHAIN1
      define_method_handler(:foo) do
        100
      end
    end
    
    CHAIN1.new.foo.should be == 100
  end
  
end