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
    
    def execute?(chain, *args)
      if @condition
        tmp_method = "tmpmethod#{rand(1000000)}#{Time.now.to_i}"
        begin
          local_condition = @condition
          chain.class.class_eval do 
            define_method(tmp_method, &local_condition)
          end
          chain.send(tmp_method,*args)
        ensure
          begin
            chain.class.class_eval do
              remove_method(tmp_method)
            end
          rescue NameError
          end
        end
      else
        true
      end
    end
    
    def condition(&blk)
      @condition = blk
      self
    end
  end
  
  module ChainMethods
    def disabled_handler_groups
      @disabled_handler_groups ||= Hash.new
    end
    
    def enable_handler_group(groupname, mname = self.class.method_handlers.keys.first)
      group_included = false
      if block_given?
        old_groups = (disabled_handler_groups[mname]||Set.new).dup
        begin
          enable_handler_group(groupname,mname)
          yield
        ensure
          self.disabled_handler_groups[mname] = old_groups
        end
      else
        disabled_handler_groups[mname] ||= Set.new
        disabled_handler_groups[mname].delete(groupname)
      end
    end
    
    def disable_handler_group(groupname, mname = self.class.method_handlers.keys.first)
      if block_given?
        old_groups = (disabled_handler_groups[mname]||Set.new).dup
        begin
          disable_handler_group(groupname,mname)
          yield
        ensure
          self.disabled_handler_groups[mname] = old_groups
        end
      else
        disabled_handler_groups[mname] ||= Set.new
        disabled_handler_groups[mname] << groupname
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
    
    @method_handlers ||= Hash.new
    @method_handlers[mname] ||= Array.new
    @next_priority = (@next_priority || 0) + 1
    
    mh = MethodHandler.new(blk, @next_priority, (options[:group].to_a + :default.to_a), options[:priority] || 0)
    mh.method_name = options[:method]
    
    @method_handlers[mname] << mh
    
    include ChainMethods
    
    @method_handlers[mname].sort!{|x,y| 
      if x.priority == y.priority
        x.second_priority <=> y.second_priority
       else
        x.priority <=> y.priority
      end
    }
        
    define_method(mname) do |*x, &callblk|
      retval = nil
      self.class.method_handlers[mname].reject{|mhh| 
          mhh.group.count { |gr|
            @disabled_handler_groups ||= Hash.new
            @disabled_handler_groups[mname]||= Set.new
            
            @disabled_handler_groups[mname].include? gr
          } > 0 }.reverse_each do |mhh|

        if mhh.execute?(self,*x)
          tmp_method = "tmpmethod#{rand(1000000)}#{Time.now.to_i}"
          
          begin
            if mhh.method_name
              retval = send(mhh.method_name, *x, &callblk)
              break
            else
              self.class.class_eval do 
                define_method(tmp_method, &mhh.processor)
              end
              retval = method(tmp_method).call(*x, &callblk)
              break
            end
          ensure
            unless mhh.method_name
              begin
                self.class.class_eval do
                  remove_method(tmp_method)
                end
              rescue NameError
              end
            end 
          end
        end
      end
      
      retval
    end
    
    mh
  end
end
