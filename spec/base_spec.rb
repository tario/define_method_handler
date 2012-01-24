require "define_method_handler"


describe "define_method_handler" do
  
  it "single method handler without condition should act as a method" do
    class CHAIN1
      define_method_handler(:foo) do
        100
      end
    end
    
    CHAIN1.new.foo.should be == 100
  end

  
  it "single method handler without condition should act as a method and this method should accept blocks" do
    class CHAIN2
      define_method_handler(:foo) do |&blk|
        blk.call + 1
      end
    end
    
    CHAIN2.new.foo{99}.should be == 100
  end
  
  it "two method handlers with the same name should respond depending on condition" do
    class CHAIN3
      define_method_handler(:foo) {|x|
        1
      }.condition{|x| x==3}

      define_method_handler(:foo) {|x|
        2
      }.condition{|x| x==4}
    end
    
    CHAIN3.new.foo(3).should be == 1
    CHAIN3.new.foo(4).should be == 2
  end
  
end