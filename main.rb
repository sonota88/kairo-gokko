def browser?
  Kernel.const_defined?(:Native)
end

def update_progress(msg)
  puts "update_progress: #{msg}"

  if browser?
    %x{
      var el = document.querySelector(".loading_progress");
      el.textContent += "*";
    }
  end
end

if browser?
  require "dxopal"
  update_progress "dxopal"
else
  require "./dxopal_sdl"
end

include DXOpal

require_remote "./data.rb"
update_progress "data"

require_remote "./circuit.rb"
update_progress "circuit"

require_remote "./view.rb"
update_progress "view"

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

def on_push_switch(pushed_switch)
  Sound[:click].play
  pushed_switch.toggle()
end

def update_tuden_relay_switch_lamp(circuit)
  circuit.update_tuden_state()
  circuit.switch_changed = circuit.update_not_relays_state()
  circuit.update_lamps_state()
end

def draw(view, circuit, mx, my)
  view.draw_grid(15, 11)

  circuit.child_circuits.each { |child_circuit|
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

    child_circuit.lamps.each { |lamp|
      view.draw_lamp(lamp)
    }

    child_circuit.not_relays.each { |not_relay|
      view.draw_not_relay(not_relay)
    }
  }

  view.draw_cursor_highlight(mx, my)
end

def main_loop(circuit, view)
  switch_changed = false

  mx = (Input.mouse_x / PPC).floor
  my = (Input.mouse_y / PPC).floor

  if Input.mouse_push?(M_LBUTTON)
    mpos = Point(mx, my)

    pushed_switch =
      circuit.find_switch_by_position(mpos)

    if pushed_switch
      on_push_switch(pushed_switch)
      switch_changed = true
    end
  end

  tx = (Input.touch_x / PPC).floor
  ty = (Input.touch_y / PPC).floor

  if Input.touch_push?
    tpos = Point(tx, ty)

    pushed_switch =
      circuit.find_switch_by_position(tpos)

    if pushed_switch
      on_push_switch(pushed_switch)
      switch_changed = true
    end
  end

  if switch_changed || circuit.switch_changed
    update_tuden_relay_switch_lamp(circuit)
  end

  draw(view, circuit, mx, my)
end

# --------------------------------

circuit = Circuit.from_plain(parse_json($data_json))

update_tuden_relay_switch_lamp(circuit)

view = View.new(PPC)

Sound.register(:click, "click.wav")

Window.load_resources do
  hide_loading()

  Window.bgcolor = C_BLACK

  Window.loop do
    main_loop(circuit, view)
  end
end
