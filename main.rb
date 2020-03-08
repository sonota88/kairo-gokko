def browser?
  Kernel.const_defined?(:Native)
end

if browser?
  require "dxopal"
else
  require "./dxopal_sdl"
end

include DXOpal

require_remote "./data.rb"
require_remote "./child_circuit.rb"
require_remote "./view.rb"

# pixels per cell
PPC = 30

def parse_json(json)
  if browser?
    Native(`JSON.parse(json)`)
  else
    require "json"
    JSON.parse(json)
  end
end

def hide_loading
  %x{
    var loadingContainer = document.querySelector(".loading_container");
    loadingContainer.style.display = "none";
  }
end

circuit = ChildCircuit.from_plain(
  parse_json($data_json)
)

view = View.new(PPC)

Sound.register(:click, "click.wav")

Window.load_resources do
  hide_loading()

  Window.bgcolor = C_BLACK

  Window.loop do
    mx = (Input.mouse_x / PPC).floor
    my = (Input.mouse_y / PPC).floor

    if Input.mouse_push?(M_LBUTTON)
      mpos = Point(mx, my)

      pushed_switch =
        circuit.switches.find { |switch| switch.pos == mpos }

      if pushed_switch
        Sound[:click].play
        pushed_switch.toggle()
      end
    end

    circuit.update_edges()

    view.draw_grid(10, 11)

    circuit.edges.each { |edge|
      view.draw_edge(edge)
    }

    circuit.plus_poles.each { |pole|
      view.draw_plus_pole(pole)
    }

    circuit.minus_poles.each { |pole|
      view.draw_minus_pole(pole)
    }

    circuit.switches.each { |switch|
      view.draw_switch(switch)
    }

    view.draw_cursor_highlight(mx, my)
  end
end
