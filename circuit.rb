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

end
