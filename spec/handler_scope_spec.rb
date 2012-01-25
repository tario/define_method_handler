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
    class CHAIN5_1
      handler_scope(:group => :testgroup) do
        define_method_handler(:foo) do
          100
        end
      end

      define_method_handler(:bar) do
        100
      end
    end

    chain = CHAIN5_1.new
    chain.disable_handler_group(:testgroup) do
      chain.bar.should be == 100
    end
  end
end
