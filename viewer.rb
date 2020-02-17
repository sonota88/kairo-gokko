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
end

def make_pt_pairs_map(wf_set)
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

    map[wf.pos1] << [wfwf, wf.pos2]
    map[wf.pos2] << [wfwf, wf.pos1]
  }

  map
end

def take_edge(degree_map, pt_pairs_map, pt0, wfwf, pt1)
  wfwfs = []

  wfwf.visit()
  wfwfs << wfwf

  work_pt = pt1

  loop do
    next_pairs =
      if degree_map[work_pt] == 2
        pt_pairs_map[work_pt].select { |wfwf, _| ! wfwf.visited }
      else
        # 次数が 2 以外の場合は次の経路なし
        []
      end

    break if next_pairs.empty?

    # assert
    if next_pairs.size != 1
      raise "next_pairs.size must be 1"
    end

    wfwf, next_pt = next_pairs[0]

    wfwf.visit()
    wfwfs << wfwf

    work_pt = next_pt
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

  pt_pairs_map = make_pt_pairs_map(wf_set)

  edges = []

  start_pts.each { |start_pt|
    pt_pairs_map[start_pt].each { |wfwf, next_pt|
      next if wfwf.visited
      edges << take_edge(degree_map, pt_pairs_map, start_pt, wfwf, next_pt)
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

doc = LiboDraw::Document.new(path)

wf_set = to_wire_fragments(doc.pages[0].lines)
edges = to_edges(wf_set)

drawer = Drawer.new(PPC)

draw_grid(drawer, 8, 10)

doc.pages[0].rectangles.each { |rect|
  x2 = rect.x + rect.w
  y2 = rect.y + rect.h
  drawer.draw_box(
    rect.x, rect.y,
    x2,     y2,
    C_WHITE
  )
}

wf_set.each { |wf|
  drawer.draw_line(
    wf.x1 + 0.5, wf.y1 + 0.5,
    wf.x2 + 0.5, wf.y2 + 0.5,
    C_WHITE
  )
}

# 描画する前に終了しないように待つ
sleep 60
