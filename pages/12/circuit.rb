# coding: utf-8

if RUBY_ENGINE == "opal"
  require_remote "./unit.rb"
  require_remote "./tuden.rb"
else
  require "./unit"
end

class Circuit
  attr_reader :edges
  attr_reader :plus_poles
  attr_reader :minus_poles
  attr_reader :switches

  def initialize(edges, plus_poles, minus_poles, switches)
    @edges = edges
    @plus_poles = plus_poles
    @minus_poles = minus_poles
    @switches = switches
  end

  def to_plain
    {
      edges:       @edges      .map { |it| it.to_plain },
      plus_poles:  @plus_poles .map { |it| it.to_plain },
      minus_poles: @minus_poles.map { |it| it.to_plain },
      switches:    @switches   .map { |it| it.to_plain }
    }
  end

  def self.from_plain(plain)
    edges       = plain["edges"      ].map { |it| Unit::Edge     .from_plain(it) }
    plus_poles  = plain["plus_poles" ].map { |it| Unit::PlusPole .from_plain(it) }
    minus_poles = plain["minus_poles"].map { |it| Unit::MinusPole.from_plain(it) }
    switches    = plain["switches"   ].map { |it| Unit::Switch   .from_plain(it) }

    Circuit.new(
      edges,
      plus_poles,
      minus_poles,
      switches
    )
  end

  def self.to_plus_pole(rect)
    pos = Point(
      rect.x.floor,
      rect.y.floor
    )

    Unit::PlusPole.new(pos)
  end

  def self.to_minus_pole(rect)
    pos = Point(
      rect.x.floor,
      rect.y.floor
    )

    Unit::MinusPole.new(pos)
  end

  def self.to_switch(rect)
    pos = Point(
      rect.x.floor,
      rect.y.floor
    )

    Unit::Switch.new(pos)
  end

  def self.to_wire_fragments(lines)
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

  def self.make_degree_map(wf_set)
    map = Hash.new(0)

    wf_set.each { |wf|
      map[wf.pos1] += 1
      map[wf.pos2] += 1
    }

    map
  end

  def self.select_start_points(degree_map)
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

  def self.make_pt_wfs_map(wf_set)
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

  def self.select_next_wfs(degree_map, pt_wfs_map, prev_wf, work_pt)
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

  def self.take_edge(degree_map, pt_wfs_map, pt0, wf1)
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

  def self.to_edges(wf_set)
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

  def self.create(lines, rects)
    plus_poles =
      rects
        .select { |rect| rect.text == "+" }
        .map { |rect| to_plus_pole(rect) }

    minus_poles =
      rects
        .select { |rect| rect.text == "-" }
        .map { |rect| to_minus_pole(rect) }

    switches =
      rects
        .select { |rect| rect.text == "sw" }
        .map { |rect| to_switch(rect) }

    wf_set = to_wire_fragments(lines)
    edges = to_edges(wf_set)

    Circuit.new(
      edges,
      plus_poles,
      minus_poles,
      switches
    )
  end

  def update_edges
    is_tuden = Tuden.tuden?(@switches[0])
    @edges[0].update(is_tuden)
  end

  def pretty_inspect
    to_plain.pretty_inspect
  end

end
