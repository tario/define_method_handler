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
 
  it "one method handler defined with group only should run after a group disable block" do
    class CHAIN2_1
      define_method_handler(:foo, :group => :testgroup) {
        10
      }
    end
    
    chain = CHAIN2_1.new
    chain.disable_handler_group(:testgroup) do
    end
    
    chain.foo.should be == 10
  end 

  it "one method handler defined with group only should run inside enable_handler_group" do
    class CHAIN2_1
      define_method_handler(:foo, :group => :testgroup) {
        10
      }
    end
    
    chain = CHAIN2_1.new
    chain.disable_handler_group(:testgroup) do
      chain.enable_handler_group(:testgroup) do
        chain.foo.should be == 10
      end
    end
  end
  
  it "one method handler defined with group only should NOT run inside disable_handler_group block after enable_handler_group block" do
    class CHAIN2_1
      define_method_handler(:foo, :group => :testgroup) {
        10
      }
    end
    
    chain = CHAIN2_1.new
    chain.disable_handler_group(:testgroup) do
      chain.enable_handler_group(:testgroup) do
      end
      chain.foo.should be == nil
    end
  end
  
  it "one method handler defined with group only should run inside enable_handler_group, should run" do
    class CHAIN2_1
      define_method_handler(:foo, :group => :testgroup) {
        10
      }
    end
        
    ret = nil
    chain = CHAIN2_1.new
    chain.disable_handler_group(:testgroup) do
      chain.enable_handler_group(:testgroup) do
        ret = chain.foo
      end
    end
    
    ret.should be == 10
  end


  it "one method handler defined with group should not run after disable_handler_group" do
    class CHAIN2_1
      define_method_handler(:foo, :group => :testgroup) {
        10
      }
    end
        
    chain = CHAIN2_1.new
    chain.disable_handler_group(:testgroup)
    chain.foo.should be == nil
  end
  
  it "one method handler defined with group should run after enable_handler_group" do
    class CHAIN2_1
      define_method_handler(:foo, :group => :testgroup) {
        10
      }
    end
        
    chain = CHAIN2_1.new
    chain.disable_handler_group(:testgroup)
    chain.enable_handler_group(:testgroup)
    chain.foo.should be == 10
  end   
end