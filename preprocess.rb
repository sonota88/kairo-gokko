# coding: utf-8

require "json"

require "./circuit"
require "./libo_draw"

path = ARGV[0]

page_no =
  if ARGV[1]
    ARGV[1].to_i
  else
    1
  end

doc = LiboDraw::Document.new(path)

circuits =
  doc.pages.map { |page|
    Circuit.create(
      page.name,
      page.lines,
      page.rectangles
    )
  }

plain = circuits.map { |circuit| circuit.to_plain }

puts "$data_json = <<EOB"
print JSON.pretty_generate(plain)
print "\n"
puts "EOB"
