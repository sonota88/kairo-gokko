# coding: utf-8

if RUBY_ENGINE == "opal"
  require_remote "./unit.rb"
  require_remote "./child_circuit.rb"
else
  require "./unit"
  require "./child_circuit"
end

class Circuit
  attr_reader :child_circuits

  def initialize(child_circuits)
    @child_circuits = child_circuits
  end

  def to_plain
    {
      child_circuits: @child_circuits.map { |child_circuit| child_circuit.to_plain }
    }
  end

  def self.from_plain(data)
    child_circuits =
      data["child_circuits"]
        .map { |child_circuit_data|
          ChildCircuit.from_plain(child_circuit_data)
        }

    Circuit.new(child_circuits)
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

  def self.to_lamp(rect)
    pos = Point(
      rect.x.floor,
      rect.y.floor
    )

    Unit::Lamp.new(pos)
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

  class EdgeCluster
    attr_reader :edges

    def initialize(edges)
      @edges = edges
    end

    def all_node_set
      pos_set = Set.new
      @edges.each { |edge|
        pos_set << edge.pos1
        pos_set << edge.pos2
      }
      pos_set
    end

    def connected_to?(other)
      all_node_set.intersect?(other.all_node_set)
    end

    def merge(other)
      @edges += other.edges
      other.clear()
    end

    def clear
      @edges = []
    end
  end

  def self.to_edge_groups(all_edges)
    ecs = all_edges.map { |edge| EdgeCluster.new([edge]) }

    loop do
      merge_occured = false

      ecs.combination(2).each { |ec_a, ec_b|
        if ec_a.connected_to?(ec_b)
          ec_a.merge(ec_b)
          merge_occured = true
        end
      }

      break unless merge_occured

      ecs = ecs.reject { |ec| ec.edges.empty? }
    end

    ecs.map { |ec| ec.edges }
  end

  def self.select_child_circuit_units(edges, single_cell_units)
    single_cell_units.select { |unit|
      edges.any? { |edge|
        edge.include_pos?(unit.pos)
      }
    }
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

    all_lamps =
      rects
        .select { |rect| rect.text == "L" }
        .map { |rect| to_lamp(rect) }

    wf_set = to_wire_fragments(lines)
    all_edges = to_edges(wf_set)

    edge_groups = to_edge_groups(all_edges)

    child_circuits =
      edge_groups.map { |edges|
        plus_poles  = select_child_circuit_units(edges, all_plus_poles)
        minus_poles = select_child_circuit_units(edges, all_minus_poles)
        switches    = select_child_circuit_units(edges, all_switches)
        lamps       = select_child_circuit_units(edges, all_lamps)

        ChildCircuit.new(
          edges,
          plus_poles,
          minus_poles,
          switches,
          lamps
        )
      }

    Circuit.new(child_circuits)
  end

  def find_switch_by_position(pos)
    @child_circuits.each { |child_circuit|
      pushed_switch =
        child_circuit.switches
          .find { |switch| switch.pos == pos }
      return pushed_switch if pushed_switch
    }

    nil
  end

  def update_tuden_state
    @child_circuits.each { |child_circuit|
      child_circuit.update_edges()
    }
  end

  def update_lamps_state
    @child_circuits.each { |child_circuit|
      child_circuit.update_lamps()
    }
  end
end
