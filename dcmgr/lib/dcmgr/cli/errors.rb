# -*- coding: utf-8 -*-

module Dcmgr::Cli
  class Error < StandardError
    attr_reader :exit_code
    def initialize(msg, exit_code=1)
      super(msg)
      @exit_code = exit_code
    end

    def self.raise(msg, exit_code)
      Kernel.raise(if msg.is_a?(self)
                     msg
                   else
                     self.new(msg, exit_code)
                   end)
    end
  end
  
  class UnknownUUIDError < Error
    def initialize(uuid,exit_code=100)
      super("Unknown UUID '#{uuid}'.")
    end
    
    def self.raise(uuid,exit_code=100)
      super
    end
  end
end
