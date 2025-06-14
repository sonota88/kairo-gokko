# require "./drawer"

  require_relative "drawer_dxopal.rb"

class View
  C_GRID     = [255,  40,  40,  40]
  C_POLE     = [255, 160, 160, 160]
  C_INACTIVE = [255,  40, 100,   0]
  C_ACTIVE   = [255, 130, 255,   0]
  C_CURSOR   = [127, 255, 120,   0]

  C_CHART_LABEL = [255, 160, 160, 160]
  C_CHART_LINE  = [255, 160, 160, 160]
  C_CHART_AREA  = [255,  50,  50,  50]

  C_DEBUG_TEXT  = [160, 240, 240, 0]

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

    draw_chart(circuit)

    draw_cursor_highlight(mx, my)

    @drawer.draw_font_px(
      @drawer.window_width - 60, 2, "#{@drawer.real_fps} fps",
      @drawer.create_font(16),
      color: C_DEBUG_TEXT
    )
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

    if lamp.name
      @drawer.draw_font(
        lamp.x + 1, lamp.y - 0.5,
        lamp.name,
        @drawer.create_font(12),
        color: C_DEBUG_TEXT
      )
    end
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

  def draw_equal_relay(relay)
    x = relay.x
    y = relay.y

    color = relay.on? ? [0, 170, 221] : [0, 68, 204]

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

  def draw_not_relay(relay)
    x = relay.x
    y = relay.y

    color = relay.on? ? [0, 170, 221] : [0, 68, 204]

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

    # # naive version
    # edge.wfs.each { |wf|
    #   @drawer.draw_line(
    #     wf.x1 + 0.5, wf.y1 + 0.5,
    #     wf.x2 + 0.5, wf.y2 + 0.5,
    #     color
    #   )
    # }

    edge.each_wire_line { |pt1, pt2|
      @drawer.draw_line(
        pt1.x + 0.5, pt1.y + 0.5,
        pt2.x + 0.5, pt2.y + 0.5,
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

  def draw_chart(circuit)
    hists = []
    circuit.child_circuits.each { |child_circuit|
      child_circuit.state_histories.each { |state_history|
        hists << state_history
      }
    }

    offset_x = 40
    offset_y = @drawer.window_height - 10
    height = 20

    font = @drawer.create_font(12)

    hists
      .sort_by { |hist| hist.name }
      .each { |hist|
        offset_y -= height

        l_y = offset_y + (height * 0.8)
        h_y = offset_y + (height * 0.2)

        blocks = hist.to_blocks()

        blocks
          .select { |from, to, state| state == true }
          .each { |from, to, _|
            @drawer.draw_box_fill_px(
              offset_x + from + 0.5, h_y,
              offset_x + to + 0.5, l_y,
              C_CHART_AREA
            )
          }

        blocks.each { |from, to, state|
          y = state ? h_y : l_y
          @drawer.draw_line_px(
            offset_x + from, y,
            offset_x + to  , y,
            C_CHART_LINE
          )
        }

        if 2 <= blocks.size
          blocks[0..-2].each { |_, to, state|
            y0 = state ? h_y : l_y
            y1 = (!state) ? h_y : l_y
            @drawer.draw_line_px(
              offset_x + to    , y0,
              offset_x + to + 1, y1,
              C_CHART_LINE
            )
          }
        end

        @drawer.draw_font_px(
          10, offset_y + height * 0.2, hist.name, font,
          color: C_CHART_LABEL
        )
      }
  end
end
