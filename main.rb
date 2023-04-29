require "dxopal"

def aot_compile?
  true
end

def browser?
  Kernel.const_defined?(:Native)
end

def update_progress(msg)
  return if aot_compile?

  puts "update_progress: #{msg}"

  if browser?
    %x{
      var el = document.querySelector(".loading_progress");
      el.textContent += "*";
    }
  end
end

t_before_require = Time.now

# if brower?
#   require "dxopal"
#   update_progress "dxopal"
# else
#   require "./dxopal_sdl"
# end
include DXOpal

if aot_compile?
  require_relative "data.rb"
  require_relative "circuit.rb"
  require_relative "view.rb"
else
require_remote "./data.rb"
update_progress "data"

require_remote "./circuit.rb"
update_progress "circuit"

require_remote "./view.rb"
update_progress "view"
end

# pixels per cell
PPC = 16

def parse_json(json)
  if browser? || aot_compile?
    Native(`JSON.parse(json)`)
  else
    require "json"
    JSON.parse(json)
  end
end

puts format("require done: %.02f sec", Time.now - t_before_require)

def get_els(selector, el = Native(`document`))
  el.querySelectorAll(selector)
end

def hide_loading
  loading_container = get_els(".loading_container")[0]
  loading_container.style.display = "none"
end

# --------------------------------

class PushHistory
  DURATION_SEC = 0.4
  @@history = []

  def self.add(pos)
    @@history << [pos, Time.now]
  end

  def self.sweep(now)
    @@history = @@history.select { |pos, time|
      now - time <= DURATION_SEC
    }
  end

  def self.get_for_draw(now)
    @@history.map { |pos, time|
      ratio = (now - time) / DURATION_SEC
      [pos, ratio]
    }
  end
end

def change_circuit(ci)
  $circuit = $circuits[ci]
  update_tuden_relay_switch_lamp($circuit)
end

def on_select_circuit
  option_el = get_els(".circuit_list option:checked")[0]
  ci = option_el.value.to_i

  change_circuit(ci)
end

def init_circuit_list(circuits)
  get_els(".circuit_list_container")[0].style.display = "block"

  select_el = get_els(".circuit_list")[0]

  (0...circuits.size).each { |ci|
    circuit = $circuits[ci]
    option_el = Native(`document`).createElement("option")
    option_el.value = ci.to_s
    option_el.textContent = "(%d) %s" % [ci + 1, circuit.name]
    select_el.appendChild(option_el)
  }

  select_el.addEventListener(
    "change",
    lambda { on_select_circuit() },
    false
  )
end

def on_push_switch(pushed_switch)
  Sound[:click].play
  pushed_switch.toggle()
end

def update_tuden_relay_switch_lamp(circuit)
  return if Time.now < circuit.last_update + 0.1
  circuit.last_update = Time.now

  circuit.update_tuden_state()

  switch_changed_eq = circuit.update_equal_relays_state()
  switch_changed_not = circuit.update_not_relays_state()
  circuit.switch_changed =
    switch_changed_eq || switch_changed_not

  circuit.update_lamps_state()

  Sound[:relay].play if circuit.switch_changed
end

def pushed_pos
  if Input.mouse_push?(M_LBUTTON)
    x = (Input.mouse_x / PPC).floor
    y = (Input.mouse_y / PPC).floor
    Point(x, y)
  elsif Input.touch_push?
    x = (Input.touch_x / PPC).floor
    y = (Input.touch_y / PPC).floor
    Point(x, y)
  else
    nil
  end
end

def main_loop(circuit, view)
  switch_changed = false

  mx = (Input.mouse_x / PPC).floor
  my = (Input.mouse_y / PPC).floor

  ppos = pushed_pos()

  if ppos
    PushHistory.add(ppos)

    pushed_switch =
      circuit.find_switch_by_position(ppos)

    if pushed_switch
      on_push_switch(pushed_switch)
      switch_changed = true
    end
  end

  if switch_changed || circuit.switch_changed
    update_tuden_relay_switch_lamp(circuit)
  end

  now = Time.now
  PushHistory.sweep(now)

  push_history_for_draw =
    PushHistory.get_for_draw(now)

  circuit.child_circuits.each { |child_circuit|
    child_circuit.state_histories.each { |state_history|
      lamp = child_circuit.find_lamp(state_history.name)
      state_history.shift_cursor!()
      state_history.update(lamp.on?)
    }
  }

  view.draw(
    circuit,
    mx, my,
    push_history_for_draw
  )
end

# --------------------------------

$circuits =
  parse_json($data_json)
    .map { |plain| Circuit.from_plain(plain) }

init_circuit_list($circuits) if browser?

# circuit index
ci =
  if ENV.key?("PAGE")
    ENV["PAGE"].to_i - 1
  else
    0
  end

view = View.new(PPC)

Sound.register(:click, "click.wav")
# Sound.register(:relay, "relay.wav")
Sound.register(:relay, "relay_2.wav")

Window.width  = 1200
Window.height = 600
Window.fps = 30

$circuits.each { |circuit|
  circuit.init_state_histories(
    [Window.width - 60, 400].min
  )
}

Window.load_resources do
  change_circuit(ci)
  hide_loading() if browser?

  Window.bgcolor = C_BLACK

  Window.loop do
    main_loop($circuit, view)
  end
end
