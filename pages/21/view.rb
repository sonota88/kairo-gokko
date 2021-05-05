# require "./drawer"
require_remote "./drawer_dxopal.rb"

class View
  C_GRID     = [255,  40,  40,  40]
  C_POLE     = [255, 160, 160, 160]
  C_INACTIVE = [255,  40, 100,   0]
  C_ACTIVE   = [255, 130, 255,   0]
  C_CURSOR   = [127, 255, 120,   0]

  def initialize(ppc)
    @drawer = Drawer.new(ppc)
  end

  def draw_grid(w, h)
    # tate
    (1..w).each { |x|
      @drawer.draw_line(x, 0, x, h, C_GRID)
    }

    # yoko
    (1..h).each { |y|
      @drawer.draw_line(0, y, w, y, C_GRID)
    }
  end

  def draw_plus_pole(pole)
    @drawer.draw_box_fill(
      pole.x + 0.1, pole.y + 0.1,
      pole.x + 0.9, pole.y + 0.9,
      C_BLACK
    )
    @drawer.draw_box(
      pole.x + 0.1, pole.y + 0.1,
      pole.x + 0.9, pole.y + 0.9,
      C_POLE
    )
    @drawer.draw_line(
      pole.x + 0.3, pole.y + 0.5,
      pole.x + 0.7, pole.y + 0.5,
      C_POLE
    )
    @drawer.draw_line(
      pole.x + 0.5, pole.y + 0.3,
      pole.x + 0.5, pole.y + 0.7,
      C_POLE
    )
  end

  def draw_minus_pole(pole)
    @drawer.draw_box_fill(
      pole.x + 0.1, pole.y + 0.1,
      pole.x + 0.9, pole.y + 0.9,
      C_BLACK
    )
    @drawer.draw_box(
      pole.x + 0.1, pole.y + 0.1,
      pole.x + 0.9, pole.y + 0.9,
      C_POLE
    )
    @drawer.draw_line(
      pole.x + 0.3, pole.y + 0.5,
      pole.x + 0.7, pole.y + 0.5,
      C_POLE
    )
  end

  def draw_switch(switch)
    color = switch.on? ? C_ACTIVE : C_INACTIVE

    @drawer.draw_box_fill(
      switch.x + 0.1, switch.y + 0.1,
      switch.x + 0.9, switch.y + 0.9,
      C_BLACK
    )

    @drawer.draw_box(
      switch.x + 0.1, switch.y + 0.1,
      switch.x + 0.9, switch.y + 0.9,
      color
    )

    if switch.on?
      @drawer.draw_box_fill(
        switch.x + 0.3, switch.y + 0.3,
        switch.x + 0.7, switch.y + 0.4,
        color
      )
    else
      @drawer.draw_box_fill(
        switch.x + 0.3, switch.y + 0.6,
        switch.x + 0.7, switch.y + 0.7,
        color
      )
    end
  end

  def draw_lamp(lamp)
    color = lamp.on? ? [255, 204, 0] : [102, 85, 68]

    if lamp.on?
      @drawer.draw_circle_fill(
        lamp.x + 0.5, lamp.y + 0.5,
        1.0,
        [80, 255, 0, 100]
      )
    end

    @drawer.draw_circle(
      lamp.x + 0.5, lamp.y + 0.5,
      0.45,
      [127, *color]
    )
    @drawer.draw_circle_fill(
      lamp.x + 0.5, lamp.y + 0.5,
      0.3,
      color
    )
  end

  def draw_edge(edge)
    color = edge.on? ? C_ACTIVE : C_INACTIVE

    edge.wfs.each { |wf|
      @drawer.draw_line(
        wf.x1 + 0.5, wf.y1 + 0.5,
        wf.x2 + 0.5, wf.y2 + 0.5,
        color
      )
    }
  end

  def draw_cursor_highlight(x, y)
    @drawer.draw_box(
      x + 0, y + 0,
      x + 1, y + 1,
      C_CURSOR
    )
  end
end
