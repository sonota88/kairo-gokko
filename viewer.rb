# coding: utf-8
require "./unit"
require "./drawer"
require "./libo_draw"

# pixels per cell
PPC = 20

# colors
C_WHITE   = [255, 255, 255, 255]

# --------------------------------

def to_plus_pole(rect)
  pos = Point(
    rect.x.floor,
    rect.y.floor
  )

  Unit::PlusPole.new(pos)
end

def to_wire_fragments(lines)
  wf_set = Set.new

  lines.each { |line|
    x1 = line.x1.floor
    y1 = line.y1.floor
    x2 = line.x2.floor
    y2 = line.y2.floor

    if line.tate?
      x = x1
      y_min, y_max = [y1, y2].minmax

      (y_min...y_max).each { |y|
        wf_set << Unit::WireFragment.new(
          Point(x, y    ),
          Point(x, y + 1)
        )
      }
    else
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
    if degree == 2 || degree == 4
      # 開始点ではない
    else
      pts << pt
    end
  }

  pts
end

def make_pt_wfs_map(wf_set)
  pt_set = Set.new

  wf_set.each { |wf|
    pt_set << wf.pos1
    pt_set << wf.pos2
  }

  map = {}

  # 空配列で初期化
  pt_set.each { |pt| map[pt] = [] }

  wf_set.each { |wf|
    map[wf.pos1] << wf
    map[wf.pos2] << wf
  }

  map
end

def select_next_wfs(degree_map, pt_wfs_map, prev_wf, work_pt)
  case degree_map[work_pt]
  when 2
    pt_wfs_map[work_pt].select { |wf| ! wf.visited }

  when 4
    pt_wfs_map[work_pt].select { |wf|
      same_dir =
        if prev_wf.tate?
          wf.tate?
        else
          ! wf.tate?
        end

      ! wf.visited && same_dir
    }

  else
    # 次数が 2, 4 以外の場合は次の経路なし
    []

  end
end

def take_edge(degree_map, pt_wfs_map, pt0, wf1)
  wfs = []

  wf1.visit()
  wfs << wf1

  prev_wf = wf1
  work_pt = wf1.opposite_pos(pt0)

  loop do
    next_wfs =
      select_next_wfs(
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
  degree_map = make_degree_map(wf_set)
  start_pts = select_start_points(degree_map)
  pt_wfs_map = make_pt_wfs_map(wf_set)

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
    .map { |rect| to_plus_pole(rect) }

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

# 描画する前に終了しないように待つ
sleep 60
