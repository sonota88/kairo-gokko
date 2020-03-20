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

    def name
      @el["draw:name"]
    end
  end

  class Rectangle
    def initialize(el)
      @el = el
    end

    def paragraphs
      para_els = REXML::XPath.match(@el, "text:p")

      para_els.map { |para_el|
        para_el.children
          .map { |child_el|
            case child_el
            when REXML::Text
              child_el.value
            when REXML::Element
              if child_el.name == "line-break"
                "\n"
              elsif child_el.name == "span"
                child_el.text
              else
                pp child_el.name, child_el
                raise "unknown element"
              end
            else
              raise "unknown element"
            end
          }
          .join("")
      }
    end

    def text
      paragraphs.join("\n")
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

    def x; @el["svg:x"].sub(/cm$/, "").to_f; end
    def y; @el["svg:y"].sub(/cm$/, "").to_f; end
    def w; @el["svg:width"].sub(/cm$/, "").to_f; end
    def h; @el["svg:height"].sub(/cm$/, "").to_f; end
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

    def x1; @el["svg:x1"].sub(/cm$/, "").to_f; end
    def y1; @el["svg:y1"].sub(/cm$/, "").to_f; end
    def x2; @el["svg:x2"].sub(/cm$/, "").to_f; end
    def y2; @el["svg:y2"].sub(/cm$/, "").to_f; end

    def tate?
      x1.floor == x2.floor
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
