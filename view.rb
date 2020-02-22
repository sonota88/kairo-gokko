class View
  def initialize(drawer)
    @drawer = drawer
  end

  def draw_grid(w, h)
    color = [60, 60, 60]

    # tate
    (1..w).each { |x|
      @drawer.draw_line(x, 0, x, h, color)
    }

    # yoko
    (1..h).each { |y|
      @drawer.draw_line(0, y, w, y, color)
    }
  end

end
