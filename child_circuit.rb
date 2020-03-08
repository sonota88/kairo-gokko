# coding: utf-8

if RUBY_ENGINE == "opal"
  require_remote "./unit.rb"
  require_remote "./tuden.rb"
else
  require "./unit"
end

class ChildCircuit
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

    ChildCircuit.new(
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
    all_plus_poles =
      rects
        .select { |rect| rect.text == "+" }
        .map { |rect| to_plus_pole(rect) }

    all_minus_poles =
      rects
        .select { |rect| rect.text == "-" }
        .map { |rect| to_minus_pole(rect) }

    all_switches =
      rects
        .select { |rect| rect.text == "sw" }
        .map { |rect| to_switch(rect) }

    wf_set = to_wire_fragments(lines)
    all_edges = to_edges(wf_set)

    ChildCircuit.new(
      all_edges,
      all_plus_poles,
      all_minus_poles,
      all_switches
    )
  end

  def update_4_edges
    edges_connected_to_plus =
      @edges.select { |edge|
        edge.connected_to?(@plus_poles[0].pos)
      }
    edges_connected_to_minus =
      @edges.select { |edge|
        edge.connected_to?(@minus_poles[0].pos)
      }

    if edges_connected_to_plus.size == 1 &&
       edges_connected_to_minus.size == 1
      # OK
    else
      raise "not yet implemented"
    end

    edge_connected_to_plus = edges_connected_to_plus[0]
    edge_connected_to_minus = edges_connected_to_minus[0]

    center_edges =
      @edges.reject { |edge|
        edge == edge_connected_to_plus ||
        edge == edge_connected_to_minus
      }

    center_edges.each { |edge|
      switches = @switches.select { |switch|
        edge.include_pos?(switch.pos)
      }
      is_tuden = Tuden.tuden?(switches)
      edge.update(is_tuden)
    }

    is_tuden_center =
      center_edges.any? { |edge| edge.on? }

    edge_connected_to_plus.update(is_tuden_center)
    edge_connected_to_minus.update(is_tuden_center)
  end

  def switches_for_edge(edge)
    @switches.select { |switch|
      edge.include_pos?(switch.pos)
    }
  end

  def pos_set_all
    pos_set = Set.new

    @edges.each { |edge|
      pos_set << edge.pos1
      pos_set << edge.pos2
    }

    pos_set
  end

  def prepare_tuden_nodes
    nid_plus = nil
    nid_minus = nil

    pos_nid_map = {}

    tnodes = []
    pos_set_all.each_with_index { |pos, index|
      nid = index + 1

      tnodes << Tuden::Node.new(nid)

      pos_nid_map[pos] = nid

      if pos == @plus_poles[0].pos
        nid_plus = nid
      elsif pos == @minus_poles[0].pos
        nid_minus = nid
      end
    }

    [tnodes, pos_nid_map, nid_plus, nid_minus]
  end

  def prepare_tuden_edges(pos_nid_map)
    eid_edge_map = {}

    tedges = []
    @edges.each_with_index { |edge, index|
      eid = index + 1

      nid1 = pos_nid_map[edge.pos1]
      nid2 = pos_nid_map[edge.pos2]

      switches = switches_for_edge(edge)

      tedges <<
        Tuden::Edge.new(
          eid, nid1, nid2,
          switches.all? { |switch| switch.on? }
        )

      eid_edge_map[eid] = edge
    }

    [tedges, eid_edge_map]
  end

  def update_many_edges
    tnodes, pos_nid_map, nid_plus, nid_minus =
      prepare_tuden_nodes()

    tedges, eid_edge_map =
      prepare_tuden_edges(pos_nid_map)

    Tuden.update(
      tedges,
      tnodes,
      nid_plus,
      nid_minus
    )

    tedges.each { |tedge|
      edge = eid_edge_map[tedge.id]
      edge.update(tedge.on?)
    }
  end

  def update_edges
    case @edges.size
    when 1
      is_tuden = Tuden.tuden?(@switches)
      @edges[0].update(is_tuden)
    when 4
      update_4_edges()
    else
      update_many_edges()
    end
  end

  def pretty_inspect
    to_plain.pretty_inspect
  end

end
