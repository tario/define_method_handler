=begin

This file is part of the define_method_handler project, http://github.com/tario/define_method_handler

Copyright (c) 2011 Roberto Dario Seminara <robertodarioseminara@gmail.com>

define_method_handler is free software: you can redistribute it and/or modify
it under the terms of the gnu general public license as published by
the free software foundation, either version 3 of the license, or
(at your option) any later version.

define_method_handler is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.  see the
gnu general public license for more details.

you should have received a copy of the gnu general public license
along with define_method_handler.  if not, see <http://www.gnu.org/licenses/>.

=end
require "set"
class Class
  
  class MethodHandler
    attr_reader :processor

    def initialize(processor)
      @processor = processor
    end
    
    def execute?(*args)
      @condition ? @condition.call(*args) : true
    end
    
    def condition(&blk)
      @condition = blk
      self
    end
  end
  
  def method_handlers
    @method_handlers
  end
  
  def define_method_handler(mname, &blk)
    
    @method_handlers ||= Array.new
    mh = MethodHandler.new(blk)
    @method_handlers << mh
        
    define_method(mname) do |*x, &callblk|
      self.class.method_handlers.each do |mhh|
        if mhh.execute?(*x)
          return mhh.processor.call(*x, &callblk)
        end
      end
      
      nil
    end
    
    mh
  end
end