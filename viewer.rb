# coding: utf-8
require "./circuit"
require "./unit"
require "./drawer"
require "./libo_draw"
require "./view"

# pixels per cell
PPC = 30

# colors
C_WHITE   = [255, 255, 255, 255]

# --------------------------------

path = ARGV[0]

page_no =
  if ARGV[1]
    ARGV[1].to_i
  else
    1
  end

doc = LiboDraw::Document.new(path)
page = doc.pages[page_no - 1]

circuit = Circuit.create(
  page.lines,
  page.rectangles
)

drawer = Drawer.new(PPC)
view = View.new(drawer)

view.draw_grid(8, 10)

circuit.plus_poles.each { |pole|
  view.draw_plus_pole(pole)
}

circuit.minus_poles.each { |pole|
  view.draw_minus_pole(pole)
}

circuit.edges.each { |edge|
  edge.wfs.each { |wf|
    drawer.draw_line(
      wf.x1 + 0.5, wf.y1 + 0.5,
      wf.x2 + 0.5, wf.y2 + 0.5,
      C_WHITE
    )
  }
}

# 描画する前に終了しないように待つ
sleep 60
