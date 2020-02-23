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
    Window.draw_font(0, 0, "Hello!", Font.default, color: C_WHITE)
  end
end
