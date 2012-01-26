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
class Symbol
  def to_a
    [self]
  end
end

class Class
  class MethodHandler
    attr_reader :processor
    attr_reader :priority
    attr_reader :second_priority
    attr_reader :group
    attr_accessor :method_name
    
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
      group_included = false
      if block_given?
        begin
          group_included = @disabled_handler_groups.include? groupname
          enable_handler_group(groupname)
          yield
        ensure
          @disabled_handler_groups << groupname if group_included
        end
      else
        @disabled_handler_groups ||= Set.new
        @disabled_handler_groups.delete(groupname)
      end
    end
    
    def disable_handler_group(groupname)
      if block_given?
        old_groups = @disabled_handler_groups && @disabled_handler_groups.dup
        begin
          disable_handler_group(groupname)
          yield
        ensure
          @disabled_handler_groups = old_groups
        end
      else
        @disabled_handler_groups ||= Set.new
        @disabled_handler_groups << groupname
      end
    end
  end
  
  def method_handlers
    @method_handlers
  end
  
  def handler_scope(options)
    old_options = @method_handler_options||{}
    old_group = old_options[:group]
    @method_handler_options = (@method_handler_options || {}).merge(options)
    @method_handler_options[:group] = (@method_handler_options[:group].to_a + old_group.to_a).uniq

    yield
  ensure
    @method_handler_options = old_options
  end
  
  def define_method_handler(mname, *options, &blk)
    options = options.inject(&:merge) || {}
    options.merge!(@method_handler_options) if @method_handler_options 
    
    @method_handlers ||= Array.new
    @next_priority = (@next_priority || 0) + 1
    
    mh = MethodHandler.new(blk, @next_priority, (options[:group].to_a + :default.to_a), options[:priority] || 0)
    mh.method_name = options[:method]
    
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
      self.class.method_handlers.reject{|mhh| 
          mhh.group.count { |gr|
            (@disabled_handler_groups||[]).include? gr
          } > 0 }.reverse_each do |mhh|

        if mhh.execute?(*x)
          tmp_method = "tmpmethod#{rand(1000000)}#{Time.now.to_i}"
          
          begin
            if mhh.method_name
              return send(mhh.method_name, *x, &callblk)
            else
              self.class.class_eval do 
                define_method(tmp_method, &mhh.processor)
              end
              return method(tmp_method).call(*x, &callblk)
            end
          ensure
            unless mhh.method_name
              self.class.class_eval do
                remove_method(tmp_method)
              end
            end 
          end
        end
      end
      
      nil
    end
    
    mh
  end
end
