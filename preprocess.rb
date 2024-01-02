require "json"

require "./circuit"
require "./libo_draw"

path = ARGV[0]

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
print JSON.generate(plain)
print "\n"
puts "EOB"
