class Drawer
  def initialize(ppc)
    @ppc = ppc
  end

  def draw_line(x1, y1, x2, y2, color)
    Window.draw_line(
      x1 * @ppc, y1 * @ppc,
      x2 * @ppc, y2 * @ppc,
      color
    )
  end

  def draw_polyline(pts, color, close_path: false)
    pts.each_cons(2) { |pt_a, pt_b|
      draw_line(
        pt_a.x, pt_a.y,
        pt_b.x, pt_b.y,
        color
      )
    }

    if close_path
      pt_l = pts.last
      pt_f = pts.first

      draw_line(
        pt_l.x, pt_l.y,
        pt_f.x, pt_f.y,
        color
      )
    end
  end

  def draw_box(x1, y1, x2, y2, color)
    Window.draw_box(
      x1 * @ppc, y1 * @ppc,
      x2 * @ppc, y2 * @ppc,
      color
    )
  end

  def draw_box_fill(x1, y1, x2, y2, color)
    Window.draw_box_fill(
      x1 * @ppc, y1 * @ppc,
      x2 * @ppc, y2 * @ppc,
      color
    )
  end

  def draw_circle(x, y, r, color)
    Window.draw_circle(
      x * @ppc, y * @ppc,
      r * @ppc,
      color
    )
  end

  def draw_circle_fill(x, y, r, color)
    Window.draw_circle_fill(
      x * @ppc, y * @ppc,
      r * @ppc,
      color
    )
  end
end
