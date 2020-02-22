# coding: utf-8
require "./circuit"
require "./unit"
require "./drawer"
require "./libo_draw"

# pixels per cell
PPC = 30

# colors
C_WHITE   = [255, 255, 255, 255]

# --------------------------------

def take_edge(degree_map, pt_wfs_map, pt0, wf1)
  wfs = []

  wf1.visit()
  wfs << wf1

  prev_wf = wf1
  work_pt = wf1.opposite_pos(pt0)

  loop do
    next_wfs =
      Circuit.select_next_wfs(
        degree_map,
        pt_wfs_map,
        prev_wf,
        work_pt
      )

    case next_wfs.size
    when 0
      break
    when 1
      # OK
    else
      # assert
      raise "next_wfs.size must be 0 or 1"
    end

    next_wf = next_wfs[0]

    next_wf.visit()
    wfs << next_wf

    prev_wf = next_wf
    work_pt = next_wf.opposite_pos(work_pt)
  end

  Unit::Edge.new(
    pt0,
    work_pt,
    wfs
  )
end

def to_edges(wf_set)
  degree_map = Circuit.make_degree_map(wf_set)
  start_pts = Circuit.select_start_points(degree_map)
  pt_wfs_map = Circuit.make_pt_wfs_map(wf_set)

  edges = []

  start_pts.each { |start_pt|
    pt_wfs_map[start_pt].each { |wf|
      next if wf.visited
      edges << take_edge(degree_map, pt_wfs_map, start_pt, wf)
    }
  }

  edges
end

def draw_grid(drawer, w, h)
  color = [60, 60, 60]

  # tate
  (1..w).each { |x|
    drawer.draw_line(x, 0, x, h, color)
  }

  # yoko
  (1..h).each { |y|
    drawer.draw_line(0, y, w, y, color)
  }
end

# --------------------------------

path = ARGV[0]

page =
  if ARGV[1]
    ARGV[1].to_i
  else
    1
  end

doc = LiboDraw::Document.new(path)

rects = doc.pages[page - 1].rectangles

plus_poles =
  rects
    .select { |rect| rect.text == "+" }
    .map { |rect| Circuit.to_plus_pole(rect) }

minus_poles =
  rects
    .select { |rect| rect.text == "-" }
    .map { |rect| Circuit.to_minus_pole(rect) }

wf_set = Circuit.to_wire_fragments(doc.pages[page - 1].lines)
edges = to_edges(wf_set)

circuit = Circuit.new(
  edges,
  plus_poles,
  minus_poles
)

drawer = Drawer.new(PPC)

draw_grid(drawer, 8, 10)

circuit.plus_poles.each { |pole|
  drawer.draw_box(
    pole.x + 0.1, pole.y + 0.1,
    pole.x + 0.9, pole.y + 0.9,
    C_WHITE
  )
  drawer.draw_line(
    pole.x + 0.3, pole.y + 0.5,
    pole.x + 0.7, pole.y + 0.5,
    C_WHITE
  )
  drawer.draw_line(
    pole.x + 0.5, pole.y + 0.3,
    pole.x + 0.5, pole.y + 0.7,
    C_WHITE
  )
}

circuit.minus_poles.each { |pole|
  drawer.draw_box(
    pole.x + 0.1, pole.y + 0.1,
    pole.x + 0.9, pole.y + 0.9,
    C_WHITE
  )
  drawer.draw_line(
    pole.x + 0.3, pole.y + 0.5,
    pole.x + 0.7, pole.y + 0.5,
    C_WHITE
  )
}

circuit.edges.each { |edge|
  edge.wfs.each { |wf|
    drawer.draw_line(
      wf.x1 + 0.5, wf.y1 + 0.5,
      wf.x2 + 0.5, wf.y2 + 0.5,
      C_WHITE
    )
  }
}

# 描画する前に終了しないように待つ
sleep 60
