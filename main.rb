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

Window.load_resources do
  Window.bgcolor = C_BLACK

  Window.loop do
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
  end
end
