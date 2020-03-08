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

def find_pushed_switch(child_circuits, mpos)
  child_circuits.each { |child_circuit|
    pushed_switch =
      child_circuit.switches
        .find { |switch| switch.pos == mpos }
    return pushed_switch if pushed_switch
  }
end

child_circuits =
  parse_json($data_json).map { |child_circuit_data|
    ChildCircuit.from_plain(child_circuit_data)
  }

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
        find_pushed_switch(child_circuits, mpos)

      if pushed_switch
        Sound[:click].play
        pushed_switch.toggle()
      end
    end

    child_circuits.each { |child_circuit|
      child_circuit.update_edges()
    }

    view.draw_grid(10, 11)

    child_circuits.each { |child_circuit|
      child_circuit.edges.each { |edge|
        view.draw_edge(edge)
      }

      child_circuit.plus_poles.each { |pole|
        view.draw_plus_pole(pole)
      }

      child_circuit.minus_poles.each { |pole|
        view.draw_minus_pole(pole)
      }

      child_circuit.switches.each { |switch|
        view.draw_switch(switch)
      }
    }

    view.draw_cursor_highlight(mx, my)
  end
end
