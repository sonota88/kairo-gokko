module Unit

  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def hash
      [@x, @y].hash
    end

    def eql?(other)
      return false if other.nil?
      @x == other.x && @y == other.y
    end

    def inspect
      "(%s)" % [
        "Pt", @x, @y
      ].join(" ")
    end
  end

end

def Point(x, y)
  Unit::Point.new(x, y)
end
