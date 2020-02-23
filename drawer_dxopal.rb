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

  def draw_box(x1, y1, x2, y2, color)
    Window.draw_box(
      x1 * @ppc, y1 * @ppc,
      x2 * @ppc, y2 * @ppc,
      color
    )
  end
end
