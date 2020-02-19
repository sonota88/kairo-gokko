# coding: utf-8
require "./unit"
require "./drawer"
require "./libo_draw"

# pixels per cell
PPC = 20

# colors
C_WHITE   = [255, 255, 255, 255]

# --------------------------------

def to_wire_fragments(lines)
  wf_set = Set.new

  lines.each { |line|
    x1 = line.x1.floor
    y1 = line.y1.floor
    x2 = line.x2.floor
    y2 = line.y2.floor

    if line.tate?
      # tate
      x = x1
      y_min, y_max = [y1, y2].minmax

      (y_min...y_max).each { |y|
        wf_set << Unit::WireFragment.new(
          Point(x, y    ),
          Point(x, y + 1)
        )
      }
    else # yoko
      x_min, x_max = [x1, x2].minmax
      y = y1

      (x_min...x_max).each { |x|
        wf_set << Unit::WireFragment.new(
          Point(x    , y),
          Point(x + 1, y)
        )
      }
    end
  }

  wf_set
end

def make_degree_map(wf_set)
  map = Hash.new(0)

  wf_set.each { |wf|
    map[wf.pos1] += 1
    map[wf.pos2] += 1
  }

  map
end

def select_start_points(degree_map)
  pts = []

  degree_map.each { |pt, degree|
    if degree != 2
      pts << pt
    end
  }

  pts
end

class WireFragmentWithFrag
  attr_reader :visited
  attr_reader :wf

  def initialize(wf)
    @wf = wf
    @visited = false
  end

  def visit
    @visited = true
  end

  def opposite_pos(pos)
    @wf.opposite_pos(pos)
  end
end

def make_pt_wfwfs_map(wf_set)
  pt_set = Set.new

  wf_set.each { |wf|
    pt_set << wf.pos1
    pt_set << wf.pos2
  }

  map = {}

  # 空配列で初期化
  pt_set.each { |pt| map[pt] = [] }

  wf_set.each { |wf|
    wfwf = WireFragmentWithFrag.new(wf)

    map[wf.pos1] << wfwf
    map[wf.pos2] << wfwf
  }

  map
end

def take_edge(degree_map, pt_wfwfs_map, pt0, wfwf)
  wfwfs = []

  wfwf.visit()
  wfwfs << wfwf

  work_pt = wfwf.opposite_pos(pt0)

  loop do
    next_wfwfs =
      if degree_map[work_pt] == 2
        pt_wfwfs_map[work_pt].select { |wfwf| ! wfwf.visited }
      else
        # 次数が 2 以外の場合は次の経路なし
        []
      end

    case next_wfwfs.size
    when 0
      break
    when 1
      # OK
    else
      # assert
      raise "next_wfwfs.size must be 1" # must not happen
    end

    wfwf = next_wfwfs[0]

    wfwf.visit()
    wfwfs << wfwf

    work_pt = wfwf.opposite_pos(work_pt)
  end

  Unit::Edge.new(
    pt0,
    work_pt,
    wfwfs.map { |wfwf| wfwf.wf },
  )
end

def to_edges(wf_set)
  degree_map = make_degree_map(wf_set)

  start_pts = select_start_points(degree_map)

  pt_wfwfs_map = make_pt_wfwfs_map(wf_set)

  edges = []

  start_pts.each { |start_pt|
    pt_wfwfs_map[start_pt].each { |wfwf|
      next if wfwf.visited
      edges << take_edge(degree_map, pt_wfwfs_map, start_pt, wfwf)
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

def rand_color(n)
  colors = [
    [255,   0,   0],
    [  0, 255,   0],
    [  0,   0, 255],
    [255, 255,   0],
    [  0, 255, 255],
    [255,   0, 255],
    [255, 255, 255],
    [127, 127, 127],
  ]

  ci = n % colors.size
  colors[ci]
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

wf_set = to_wire_fragments(doc.pages[page - 1].lines)
edges = to_edges(wf_set)

drawer = Drawer.new(PPC)

draw_grid(drawer, 8, 10)

doc.pages[page - 1].rectangles.each { |rect|
  x2 = rect.x + rect.w
  y2 = rect.y + rect.h
  drawer.draw_box(
    rect.x, rect.y,
    x2,     y2,
    C_WHITE
  )
}

edges.each { |edge|
edge.wfs.each { |wf|
  drawer.draw_line(
    wf.x1 + 0.5, wf.y1 + 0.5,
    wf.x2 + 0.5, wf.y2 + 0.5,
    C_WHITE
  )
}
}

edges.shuffle.each_with_index { |edge, i|
  edge.wfs.each { |wf|
    drawer.draw_line(
      wf.x1 + 0.5, wf.y1 + 0.5,
      wf.x2 + 0.5, wf.y2 + 0.5,
      rand_color(i)
    )
  }
}

edges.shuffle.each_with_index { |edge, i|
  x1 = edge.pos1.x
  y1 = edge.pos1.y
  x2 = edge.pos2.x
  y2 = edge.pos2.y

  drawer.draw_circle_fill(
    x1 + 0.5, y1 + 0.5,
    0.2,
    [0, 0, 0]
  )
  drawer.draw_circle_fill(
    x2 + 0.5, y2 + 0.5,
    0.2,
    [0, 0, 0]
  )
  drawer.draw_circle_fill(
    x1 + 0.5, y1 + 0.5,
    0.1,
    [255, 0, 0]
  )
  drawer.draw_circle_fill(
    x2 + 0.5, y2 + 0.5,
    0.1,
    [255, 0, 0]
  )
}

# 描画する前に終了しないように待つ
sleep 60
