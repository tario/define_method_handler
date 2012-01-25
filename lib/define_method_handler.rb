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
    attr_reader :priority
    attr_reader :second_priority
    attr_reader :group
    
    def initialize(processor, sprior, group, prior = 0)
      @processor = processor
      @priority = prior
      @second_priority = sprior
      @group = group
    end
    
    def execute?(*args)
      @condition ? @condition.call(*args) : true
    end
    
    def condition(&blk)
      @condition = blk
      self
    end
  end
  
  module ChainMethods
    def enable_handler_group(groupname)
      @disabled_handler_groups ||= Set.new
      group_included = @disabled_handler_groups.include? groupname
      @disabled_handler_groups.delete(groupname)
      yield
    ensure
      @disabled_handler_groups << groupname if group_included
    end
    
    def disable_handler_group(groupname)
      @disabled_handler_groups ||= Set.new
      @disabled_handler_groups << groupname
      yield
    ensure
      @disabled_handler_groups.delete groupname
    end
  end
  
  def method_handlers
    @method_handlers
  end
  
  def define_method_handler(mname, *options, &blk)
    options = options.inject(&:merge) || {}
    
    @method_handlers ||= Array.new
    @next_priority = (@next_priority || 0) + 1
    
    mh = MethodHandler.new(blk, @next_priority, options[:group] || :default, options[:priority] || 0)
    @method_handlers << mh
    
    include ChainMethods
    
    @method_handlers.sort!{|x,y| 
      if x.priority == y.priority
        x.second_priority <=> y.second_priority
      else
        x.priority <=> y.priority
      end
    }
        
    define_method(mname) do |*x, &callblk|
      self.class.method_handlers.reject{|mhh| (@disabled_handler_groups||[]).include? mhh.group }.reverse_each do |mhh|
        if mhh.execute?(*x)
          return mhh.processor.call(*x, &callblk)
        end
      end
      
      nil
    end
    
    mh
  end
end