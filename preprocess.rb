# coding: utf-8

require "json"

require "./circuit"
require "./unit"
require "./libo_draw"

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

print JSON.pretty_generate(circuit.to_plain)
print "\n"
