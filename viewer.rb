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
  drawer.draw_box(
    pole.x + 0.1, pole.y + 0.1,
    pole.x + 0.9, pole.y + 0.9,
    C_WHITE
  )
  drawer.draw_line(
    pole.x + 0.3, pole.y + 0.5,
    pole.x + 0.7, pole.y + 0.5,
    C_WHITE
  )
  drawer.draw_line(
    pole.x + 0.5, pole.y + 0.3,
    pole.x + 0.5, pole.y + 0.7,
    C_WHITE
  )
}

circuit.minus_poles.each { |pole|
  drawer.draw_box(
    pole.x + 0.1, pole.y + 0.1,
    pole.x + 0.9, pole.y + 0.9,
    C_WHITE
  )
  drawer.draw_line(
    pole.x + 0.3, pole.y + 0.5,
    pole.x + 0.7, pole.y + 0.5,
    C_WHITE
  )
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
