# coding: utf-8

require "json"

require "./child_circuit"
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

child_circuit = ChildCircuit.create(
  page.lines,
  page.rectangles
)

puts "$data_json = <<EOB"
print JSON.pretty_generate(child_circuit.to_plain)
print "\n"
puts "EOB"
