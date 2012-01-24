require "define_method_handler"


describe "define_method_handler" do
 
  it "one method handler defined with group only should run when that group is enabled" do
    class CHAIN2_1
      define_method_handler(:foo, :group => :testgroup) {
        10
      }
    end
    
    CHAIN2_1.new.foo.should be == 10
  end

  it "one method handler defined with group only should not run when that group is disabled" do
    class CHAIN2_1
      define_method_handler(:foo, :group => :testgroup) {
        10
      }
    end
    
    chain = CHAIN2_1.new
    chain.disable_handler_group(:testgroup) do
      chain.foo.should be == nil
    end
  end

end