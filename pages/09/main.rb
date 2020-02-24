require 'dxopal'
include DXOpal

require_remote "./data.rb"
require_remote "./circuit.rb"
require_remote "./view.rb"

# pixels per cell
PPC = 30

def parse_json(json)
  Native(`JSON.parse(json)`)
end

circuit = Circuit.from_plain(
  parse_json($data_json)
)

view = View.new(PPC)

Sound.register(:click, "click.wav")

Window.load_resources do
  Window.bgcolor = C_BLACK

  Window.loop do
    mx = (Input.mouse_x / PPC).floor
    my = (Input.mouse_y / PPC).floor

    if Input.mouse_push?(M_LBUTTON)
      Sound[:click].play
    end

    view.draw_grid(8, 10)

    circuit.plus_poles.each { |pole|
      view.draw_plus_pole(pole)
    }

    circuit.minus_poles.each { |pole|
      view.draw_minus_pole(pole)
    }

    circuit.edges.each { |edge|
      view.draw_edge(edge)
    }

    view.draw_cursor_highlight(mx, my)
  end
end
