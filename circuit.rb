# coding: utf-8
class Circuit
  attr_reader :edges
  attr_reader :plus_poles
  attr_reader :minus_poles

  def initialize(edges, plus_poles, minus_poles)
    @edges = edges
    @plus_poles = plus_poles
    @minus_poles = minus_poles
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

end
