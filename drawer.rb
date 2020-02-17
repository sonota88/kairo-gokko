require "plumo"

class Drawer
  def initialize(ppc)
    @ppc = ppc

    @plumo = Plumo.new(640, 480)
    @plumo.start
  end

  def to_web_rgba(color)
    rgba = color[0..2]

    rgba <<
      if color.size == 4
        color[3].to_f / 255
      else
        1.0
      end

    "rgba(%s)" % rgba.join(", ")
  end

  def draw_line(x1, y1, x2, y2, color)
    @plumo.color to_web_rgba(color)
    @plumo.line(
      x1 * @ppc, y1 * @ppc,
      x2 * @ppc, y2 * @ppc
    )
  end

  def draw_box(x1, y1, x2, y2, color)
    w = x2 - x1
    h = y2 - y1
    @plumo.color to_web_rgba(color)
    @plumo.stroke_rect(
      x1 * @ppc, y1 * @ppc,
      w * @ppc, h * @ppc
    )
  end

  def draw_circle_fill(x, y, r, color)
    @plumo.color to_web_rgba(color)
    @plumo.fill_circle(
      x * @ppc, y * @ppc,
      r * @ppc
    )
  end
end
