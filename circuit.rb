class Circuit
  attr_reader :edges
  attr_reader :plus_poles
  attr_reader :minus_poles

  def initialize(edges, plus_poles, minus_poles)
    @edges = edges
    @plus_poles = plus_poles
    @minus_poles = minus_poles
  end

  def self.to_plus_pole(rect)
    pos = Point(
      rect.x.floor,
      rect.y.floor
    )

    Unit::PlusPole.new(pos)
  end

  def self.to_minus_pole(rect)
    pos = Point(
      rect.x.floor,
      rect.y.floor
    )

    Unit::MinusPole.new(pos)
  end

  def self.to_wire_fragments(lines)
    wf_set = Set.new

    lines.each { |line|
      x1 = line.x1.floor
      y1 = line.y1.floor
      x2 = line.x2.floor
      y2 = line.y2.floor

      if line.tate?
        x = x1
        y_min, y_max = [y1, y2].minmax

        (y_min...y_max).each { |y|
          wf_set << Unit::WireFragment.new(
            Point(x, y    ),
            Point(x, y + 1)
          )
        }
      else
        x_min, x_max = [x1, x2].minmax
        y = y1

        (x_min...x_max).each { |x|
          wf_set << Unit::WireFragment.new(
            Point(x    , y),
            Point(x + 1, y)
          )
        }
      end
    }

    wf_set
  end

end
