# coding: utf-8

require "./circuit"
require "./view"

# pixels per cell
PPC = 30

# colors
C_WHITE   = [255, 255, 255, 255]

# --------------------------------

require "./data"
circuit = Circuit.from_plain(
  JSON.parse($data_json)
)

view = View.new(PPC)

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

# 描画する前に終了しないように待つ
sleep 60
