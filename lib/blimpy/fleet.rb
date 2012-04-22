
module Blimpy
  class Fleet
    attr_reader :hosts

    def initialize
      @hosts = []
    end

    def add(&block)
      if block.nil?
        return false
      end
      box = Blimpy::Box.new
      @hosts << box
      block.call(box)
    end
  end
end
