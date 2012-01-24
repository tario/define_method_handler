require "define_method_handler"


describe "define_method_handler" do
 
  it "two methods with same name and with no conditions should execute the last implementation" do
    class CHAIN1_1
      define_method_handler(:foo) {|x|
        1
      }

      define_method_handler(:foo) {|x|
        2
      }
    end
    
    CHAIN1_1.new.foo.should be == 2
  end

   it "two methods with same name and with no conditions should execute the implementation with higher priority" do
    class CHAIN1_2
      define_method_handler(:foo, :priority => 100) {|x|
        1
      }

      define_method_handler(:foo, :priority => 1) {|x|
        2
      }
    end
    
    CHAIN1_2.new.foo.should be == 1
  end
end