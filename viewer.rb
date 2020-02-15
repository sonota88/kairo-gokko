# coding: utf-8
require "./drawer"
require "./libo_draw"

# pixels per cell
PPC = 20

# colors
C_WHITE   = [255, 255, 255, 255]

# --------------------------------

def draw_grid(drawer, w, h)
  color = [60, 60, 60]

  # tate
  (1..w).each { |x|
    drawer.draw_line(x, 0, x, h, color)
  }

  # yoko
  (1..h).each { |y|
    drawer.draw_line(0, y, w, y, color)
  }
end

# --------------------------------

path = ARGV[0]

doc = LiboDraw::Document.new(path)

drawer = Drawer.new(PPC)

draw_grid(drawer, 8, 10)

doc.pages[0].rectangles.each { |rect|
  x2 = rect.x + rect.w
  y2 = rect.y + rect.h
  drawer.draw_box(
    rect.x, rect.y,
    x2,     y2,
    C_WHITE
  )
}

doc.pages[0].lines.each { |line|
  drawer.draw_line(
    line.x1, line.y1,
    line.x2, line.y2,
    C_WHITE
  )
}

# 描画する前に終了しないように待つ
sleep 60
