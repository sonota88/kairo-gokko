# require "./drawer"
require_remote "./drawer_dxopal.rb"
update_progress "drawer_dxopal"

class View
  C_GRID     = [255,  40,  40,  40]
  C_POLE     = [255, 160, 160, 160]
  C_INACTIVE = [255,  40, 100,   0]
  C_ACTIVE   = [255, 130, 255,   0]
  C_CURSOR   = [127, 255, 120,   0]

  def initialize(ppc)
    @drawer = Drawer.new(ppc)
  end

  # workarond for DXOpal
  def Point(x, y)
    Unit::Point.new(x, y)
  end

  def draw(circuit, mx, my, push_history_for_draw)
    # draw_grid(15, 11)

    push_history_for_draw.each { |pos, ratio|
      draw_push_reaction(pos, ratio)
    }

    circuit.child_circuits.each { |child_circuit|
      child_circuit.edges.each { |edge|
        draw_edge(edge)
      }

      child_circuit.plus_poles.each { |pole|
        draw_plus_pole(pole)
      }

      child_circuit.minus_poles.each { |pole|
        draw_minus_pole(pole)
      }

      child_circuit.switches.each { |switch|
        edge = child_circuit.find_edge_including_pos(switch.pos)
        draw_switch(switch, edge)
      }

      child_circuit.lamps.each { |lamp|
        draw_lamp(lamp)
      }

      child_circuit.equal_relays.each { |equal_relay|
        draw_equal_relay(equal_relay)
      }

      child_circuit.not_relays.each { |not_relay|
        draw_not_relay(not_relay)
      }
    }

    draw_cursor_highlight(mx, my)
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

  def draw_switch(switch, edge)
    color = switch.on? ? C_ACTIVE : C_INACTIVE
    color_edge = edge.on? ? C_ACTIVE : C_INACTIVE

    @drawer.draw_box_fill(
      switch.x + 0.1, switch.y + 0.1,
      switch.x + 0.9, switch.y + 0.9,
      C_BLACK
    )

    @drawer.draw_box(
      switch.x + 0.1, switch.y + 0.1,
      switch.x + 0.9, switch.y + 0.9,
      color_edge
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

  def _draw_relay_common(x, y, color)
    pts = [
      Point(x + 0.5, y - 0.3),
      Point(x + 1.3, y + 0.5),
      Point(x + 0.5, y + 1.3),
      Point(x - 0.3, y + 0.5),
    ]

    @drawer.draw_polyline(pts, color, close_path: true)

    @drawer.draw_box_fill(
      x - 0.1, y + 0.4,
      x + 1.1, y + 0.6,
      C_BLACK
    )
    @drawer.draw_box_fill(
      x + 0.4, y - 0.1,
      x + 0.6, y + 1.1,
      C_BLACK
    )
  end

  def draw_equal_relay(not_relay)
    x = not_relay.x
    y = not_relay.y

    color = not_relay.on? ? [0, 170, 221] : [0, 68, 204]

    _draw_relay_common(x, y, color)

    @drawer.draw_box_fill(
      x + 0.2, y + 0.3,
      x + 0.8, y + 0.4,
      color
    )
    @drawer.draw_box_fill(
      x + 0.2, y + 0.6,
      x + 0.8, y + 0.7,
      color
    )
  end

  def draw_not_relay(not_relay)
    x = not_relay.x
    y = not_relay.y

    color = not_relay.on? ? [0, 170, 221] : [0, 68, 204]

    _draw_relay_common(x, y, color)

    @drawer.draw_box_fill(
      x + 0.45, y + 0.2,
      x + 0.55, y + 0.55,
      color
    )
    @drawer.draw_box_fill(
      x + 0.45, y + 0.7,
      x + 0.55, y + 0.8,
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

  def draw_push_reaction(pos, ratio)
    x = pos.x
    y = pos.y
    alpha = 127 * (1 - ratio)
    r = 0.9 + ratio * 0.3

    @drawer.draw_circle_fill(
      x + 0.5, y + 0.5,
      r,
      [alpha, 150, 150, 150]
    )
  end
end
