require "define_method_handler"


describe "define_method_handler" do
  
  it "should allow use of scopes to define groups" do
    class CHAIN4_1
      handler_scope(:group => :testgroup) do
        define_method_handler(:foo) do
          100
        end
      end
    end

    chain = CHAIN4_1.new
    chain.disable_handler_group(:testgroup) do
      chain.foo.should be == nil
    end
  end
  
  
  it "method handler defined after handler_scope block should not be affected" do
    class CHAIN4_2
      handler_scope(:group => :testgroup) do
        define_method_handler(:foo) do
          100
        end
      end

      define_method_handler(:bar) do
        100
      end
    end

    chain = CHAIN4_2.new
    chain.disable_handler_group(:testgroup) do
      chain.bar.should be == 100
    end
  end
  
  it "nested handler_scopes should merge options" do
    class CHAIN4_3
      handler_scope(:group => :testgroup) do
        handler_scope(:priority => 100) do
          define_method_handler(:foo) do
            100
          end
        end
      end

      define_method_handler(:foo) do
        200
      end
    end

    chain = CHAIN4_3.new
    chain.foo.should be == 100

    chain.disable_handler_group(:testgroup) do
      chain.foo.should be == 200
    end
  end

  it "nested handler_scopes with repeated options should prioritize the more nested" do
    class CHAIN4_4
      handler_scope(:priority => -100) do
        handler_scope(:priority => 100) do
          define_method_handler(:foo) do
            100
          end
        end
      end

      define_method_handler(:foo) do
        200
      end
    end

    chain = CHAIN4_4.new
    chain.foo.should be == 100
  end
  

  it "nested handler_scopes with groups should define multiple groups for handler" do
    class CHAIN4_5
      handler_scope(:group => :a) do
         handler_scope(:group => :b) do
             define_method_handler(:foo) do
                   99
             end
         end
      end
    end
  
    chain = CHAIN4_5.new
    chain.disable_handler_group(:a) do
       chain.foo.should be == nil # nil
    end
  
    chain.disable_handler_group(:b) do
       chain.foo.should be == nil # nil
    end
  
    chain.disable_handler_group(:default) do
       chain.foo.should be == nil # nil
    end  
  end
  
end
