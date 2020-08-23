module Unit

  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def to_plain
      [@x, @y].join(",")
    end

    def self.from_plain(plain)
      x, y = plain.split(",").map { |s| s.to_f }
      Point.new(x, y)
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

    def translate(dx, dy)
      Point.new(@x + dx, @y + dy)
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

    def to_plain
      {
        pos1: @pos1.to_plain,
        pos2: @pos2.to_plain
      }
    end

    def self.from_plain(plain)
      WireFragment.new(
        Point.from_plain(plain["pos1"]),
        Point.from_plain(plain["pos2"])
      )
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

    def connected_to?(pos)
      @pos1 == pos || @pos2 == pos
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
      @state = false
    end

    def to_plain
      {
        pos1: @pos1.to_plain,
        pos2: @pos2.to_plain,
        wfs: @wfs.map { |it| it.to_plain }
      }
    end

    def self.from_plain(plain)
      Edge.new(
        Point.from_plain(plain["pos1"]),
        Point.from_plain(plain["pos2"]),
        plain["wfs"].map { |it|
          WireFragment.from_plain(it)
        }
      )
    end

    def update(state)
      @state = state
    end

    def on?
      @state
    end

    def connected_to?(pos)
      @pos1 == pos || @pos2 == pos
    end

    def include_pos?(pos)
      @wfs.any? { |wf| wf.connected_to?(pos) }
    end
  end

  class SingleCell
    attr_reader :pos

    def initialize(pos)
      @pos = pos
    end

    def x; @pos.x; end
    def y; @pos.y; end
  end

  class PlusPole < SingleCell
    def to_plain
      {
        pos: @pos.to_plain
      }
    end

    def self.from_plain(plain)
      PlusPole.new(
        Point.from_plain(plain["pos"])
      )
    end
  end

  class MinusPole < SingleCell
    def to_plain
      {
        pos: @pos.to_plain
      }
    end

    def self.from_plain(plain)
      MinusPole.new(
        Point.from_plain(plain["pos"])
      )
    end
  end

  class Switch < SingleCell
    def initialize(pos)
      super

      # ON: true / OFF: false
      @state = false
    end

    def to_plain
      {
        pos: @pos.to_plain
      }
    end

    def self.from_plain(plain)
      Switch.new(
        Point.from_plain(plain["pos"])
      )
    end

    def toggle
      @state = ! @state
    end

    def on?
      @state
    end

    def update(state)
      @state = state
    end
  end

  class Lamp < SingleCell
    attr_reader :name

    def initialize(pos, name)
      super(pos)

      # ON: true / OFF: false
      @state = false

      @name = name
    end

    def to_plain
      {
        pos: @pos.to_plain,
        name: @name
      }
    end

    def self.from_plain(plain)
      Lamp.new(
        Point.from_plain(plain["pos"]),
        plain["name"]
      )
    end

    def update(state)
      @state = state
    end

    def on?
      @state
    end
  end

  class Relay < SingleCell
    def initialize(pos)
      super

      # ON: true / OFF: false
      @state = false
    end

    def to_plain
      {
        pos: @pos.to_plain
      }
    end

    def update(state)
      @state = state
    end

    def on?
      @state
    end
  end

  class EqualRelay < Relay
    def self.from_plain(plain)
      EqualRelay.new(
        Point.from_plain(plain["pos"])
      )
    end
  end

  class NotRelay < Relay
    def self.from_plain(plain)
      NotRelay.new(
        Point.from_plain(plain["pos"])
      )
    end
  end
end

def Point(x, y)
  Unit::Point.new(x, y)
end
