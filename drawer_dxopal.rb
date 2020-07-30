class Drawer
  def initialize(ppc)
    @ppc = ppc
  end

  def adjust_px(raw_px)
    raw_px.round
  end

  def window_width
    Window.width
  end

  def window_height
    Window.height
  end

  def real_fps
    Window.real_fps
  end

  def draw_line(x1, y1, x2, y2, color)
    Window.draw_line(
      adjust_px(x1 * @ppc), adjust_px(y1 * @ppc),
      adjust_px(x2 * @ppc), adjust_px(y2 * @ppc),
      color
    )
  end

  def draw_line_px(x1, y1, x2, y2, color)
    Window.draw_line(
      adjust_px(x1), adjust_px(y1),
      adjust_px(x2), adjust_px(y2),
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
      adjust_px(x1 * @ppc), adjust_px(y1 * @ppc),
      adjust_px(x2 * @ppc), adjust_px(y2 * @ppc),
      color
    )
  end

  def draw_box_fill(x1, y1, x2, y2, color)
    Window.draw_box_fill(
      adjust_px(x1 * @ppc), adjust_px(y1 * @ppc),
      adjust_px(x2 * @ppc), adjust_px(y2 * @ppc),
      color
    )
  end

  def draw_box_fill_px(x1, y1, x2, y2, color)
    Window.draw_box_fill(
      adjust_px(x1), adjust_px(y1),
      adjust_px(x2), adjust_px(y2),
      color
    )
  end

  def draw_circle(x, y, r, color)
    Window.draw_circle(
      adjust_px(x * @ppc), adjust_px(y * @ppc),
      r * @ppc,
      color
    )
  end

  def draw_circle_fill(x, y, r, color)
    Window.draw_circle_fill(
      adjust_px(x * @ppc), adjust_px(y * @ppc),
      r * @ppc,
      color
    )
  end

  def create_font(size)
    Font.new(size, "monospace")
  end

  def draw_font_px(x, y, string, font, option={})
    Window.draw_font(
      x, y, string, font, option
    )
  end
end
