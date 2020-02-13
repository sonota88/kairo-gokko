require "plumo"
require "./libo_draw"

# pixels per cell
PPC = 20

path = ARGV[0]

doc = LiboDraw::Document.new(path)

plumo = Plumo.new(640, 480)
plumo.start

plumo.color "#fff"

doc.pages[0].rectangles.each { |rect|
  plumo.stroke_rect(
    rect.x * PPC, rect.y * PPC,
    rect.w * PPC, rect.h * PPC
  )
}

doc.pages[0].lines.each { |line|
  plumo.line(
    line.x1 * PPC, line.y1 * PPC,
    line.x2 * PPC, line.y2 * PPC
  )
}

sleep 60
