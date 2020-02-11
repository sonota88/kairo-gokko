require "rexml/document"

module LiboDraw

  class Document
    def initialize(path)
      xml = File.read(path)
      @doc = REXML::Document.new(xml)
    end

    def pages
      REXML::XPath.match(@doc, "//draw:page")
        .map { |page_el| Page.new(page_el) }
    end
  end

  class Page
    def initialize(el)
      @el = el
    end

    def rectangles
      custom_shape_els = REXML::XPath.match(@el, "draw:custom-shape")

      custom_shape_els
        .select { |el|
          geo_el = REXML::XPath.match(el, "draw:enhanced-geometry")[0]
          geo_el["draw:type"] == "rectangle"
        }
        .map { |el| Rectangle.new(el) }
    end

    def lines
      REXML::XPath.match(@el, "draw:line")
        .map { |line_el| Line.new(line_el) }
    end
  end

  class Rectangle
    def initialize(el)
      @el = el
    end

    def text
      texts = []
      @el.each_element_with_text { |el|
        texts << el.texts.join(" ")
      }
      texts.join(" ")
    end

    def inspect
      values = [
        self.class.name,
        "x=" + @el["svg:x"],
        "y=" + @el["svg:y"],
        "w=" + @el["svg:width"],
        "h=" + @el["svg:height"],
        "text=" + text.inspect,
      ]

      "(" + values.join(" ") + ")"
    end
  end

  class Line
    def initialize(el)
      @el = el
    end

    def inspect
      values = [
        self.class.name,
        "x1=" + @el["svg:x1"],
        "y1=" + @el["svg:y1"],
        "x2=" + @el["svg:x2"],
        "y2=" + @el["svg:y2"],
      ]

      "(" + values.join(" ") + ")"
    end
  end

end

# --------------------------------

if $0 == __FILE__
  require "pp"

  path = ARGV[0]

  doc = LiboDraw::Document.new(path)

  pp doc.pages[0].rectangles
  pp doc.pages[0].lines
end
