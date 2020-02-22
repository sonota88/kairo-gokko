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

    def ==(other)
      eql?(other)
    end

    def inspect
      "(%s)" % [
        "Pt", @x, @y
      ].join(" ")
    end
  end

  class WireFragment
    attr_reader :pos1, :pos2
    attr_reader :visited

    def initialize(pt1, pt2)
      @pos1 = pt1
      @pos2 = pt2
      @visited = false
    end

    def x1; @pos1.x; end
    def y1; @pos1.y; end
    def x2; @pos2.x; end
    def y2; @pos2.y; end

    def visit
      @visited = true
    end

    def opposite_pos(pos)
      if @pos1 == pos
        @pos2
      else
        @pos1
      end
    end

    def tate?
      @pos1.x == @pos2.x
    end

    def inspect
      "(%s)" % [
        "WF",
        @pos1.inspect,
        @pos2.inspect
      ].join(" ")
    end

    def hash
      [@pos1, @pos2].hash
    end

    def eql?(other)
      return false if other.nil?
      @pos1.eql?(other.pos1) && @pos2.eql?(other.pos2)
    end
  end

  class Edge
    attr_reader :wfs
    attr_reader :pos1
    attr_reader :pos2

    def initialize(pos1, pos2, wfs)
      @pos1 = pos1
      @pos2 = pos2
      @wfs = wfs
    end
  end

  class SingleCell
    attr_reader :pos

    def initialize(pos)
      @pos = pos
    end
  end

  class PlusPole < SingleCell
  end

end

def Point(x, y)
  Unit::Point.new(x, y)
end
