# coding: utf-8

class Tuden

  INFINITY = Float::INFINITY

  def initialize
    @node_map = {}
  end

  class Node
    attr_reader :id
    attr_reader :edges
    attr_reader :dist
    attr_accessor :done
    attr_accessor :from

    def initialize(id)
      @id = id
      @edges = []
    end

    def reset
      @dist = INFINITY
      @done = false
      @from = nil
    end

    def update_dist(dist, nid)
      if dist < @dist
        @dist = dist
        @from = nid
      end
    end

    def inspect
      inner = [
        "N",
        id,
        "dist=#{@dist}",
        "from=#{@from}",
        "edges=#{@edges.inspect}"
      ].join(" ")

      "(" + inner + ")"
    end
  end

  class Edge
    attr_reader :id
    attr_reader :nid1
    attr_reader :nid2
    attr_writer :state

    def initialize(id, nid1, nid2, all_switches_on)
      @id = id
      @nid1 = nid1
      @nid2 = nid2
      @state = nil
      @all_switches_on = all_switches_on
    end

    def on?
      @state
    end

    def all_switches_on?
      @all_switches_on
    end

    def opposite_nid(nid)
      if @nid1 == nid
        @nid2
      elsif @nid2 == nid
        @nid1
      else
        raise "must not happen"
      end
    end

    def connected_to?(nid)
      nid == @nid1 || nid == @nid2
    end

    def inspect
      inner = [
        "E",
        id,
        "nid=#{@nid1},#{@nid2}"
      ].join(" ")

      "(" + inner + ")"
    end
  end

  def self.tuden?(switches)
    switches.all? { |switch| switch.on? }
  end

  def find_node(nid)
    @node_map[nid]
  end

  # TODO ボトルネックになるようであれば優先度付きキューを検討
  def find_min_node(nodes)
    dist_min = nil
    min_node = nil

    nodes.each { |n|
      if ( dist_min == nil ||
           n.dist < dist_min
         )
        dist_min = n.dist
        min_node = n
      end
    }

    min_node
  end

  def make_dist_map(
        all_edges, all_nodes, nid_goal,
        nids_ignore
      )

    target_edges = all_edges.select { |edge|
      nids_ignore.all? {|nid_ignore|
        ! edge.connected_to?(nid_ignore)
      }
    }

    target_nodes = all_nodes.select { |node|
      ! nids_ignore.include?(node.id)
    }

    target_nodes.each { |node|
      node.reset()
    }

    rest_nodes = target_nodes.dup

    find_node(nid_goal).update_dist(0, nil)

    from_nid = nid_goal

    loop do
      rest_nodes = rest_nodes.select { |node| ! node.done }

      break if rest_nodes.empty?

      min_node = find_min_node(rest_nodes)
      min_node.done = true

      # TODO 改善候補
      # グラフ全体の隣接リストを作る必要はなく、
      # min_node＝対象のエッジ端点ならここで中断してよい。

      from_nid = min_node.id

      to_nodes = min_node.edges
        .map { |edge|
          nid = edge.opposite_nid(min_node.id)
          find_node(nid)
        }
        .select { |node|
          ! node.done &&
          ! nids_ignore.include?(node.id)
        }

      from_node = find_node(from_nid)

      to_dist = from_node.dist + 1
      to_nodes.each { |node|
        node.update_dist(to_dist, from_nid)
      }
    end

    dist_map = {}
    target_nodes.each { |node|
      dist_map[node.id] = [node.dist, node.from]
    }

    dist_map
  end

  def walk(dist_map, start_nid, goal_nid)
    path = [start_nid]

    return path if start_nid == goal_nid

    current_nid = start_nid

    loop do
      if dist_map.key?(current_nid)
        dist, next_nid = dist_map[current_nid]
      else
        return nil
      end

      if dist == 0
        return path
      end

      current_nid = next_nid
      path << current_nid
    end
  end

  def walk_saki_ato(
      edges,
      nodes,
      nid_saki, goal_nid_saki,
      nid_ato,  goal_nid_ato
      )

    dist_map_saki = make_dist_map(
      edges, nodes, goal_nid_saki,
      [nid_ato]
    )

    path_saki = walk(dist_map_saki, nid_saki, goal_nid_saki)

    # TODO 改善候補
    # return false if path_saki.nil?

    dist_map_ato = make_dist_map(
      edges, nodes, goal_nid_ato,
      path_saki.nil? ? [] : path_saki
    )

    path_ato = walk(dist_map_ato, nid_ato, goal_nid_ato)

    ! path_saki.nil? && ! path_ato.nil?
  end

  def edge_tuden?(
        nid_plus,
        nid_minus,
        edges,
        nodes,
        edge
      )

    return false unless edge.all_switches_on?

    # nid1 => plus
    # nid2 => mminus
    result1 =
      walk_saki_ato(
        edges,
        nodes,
        edge.nid1, nid_plus,
        edge.nid2, nid_minus
      )

    # nid1 => minus
    # nid2 => plus
    result2 =
      walk_saki_ato(
        edges,
        nodes,
        edge.nid1, nid_minus,
        edge.nid2, nid_plus
      )

    # TODO 改善候補
    result1 || result2 || false
  end

  def update(
        edges,
        nodes,
        nid_plus,
        nid_minus
      )

    nodes.each { |node| @node_map[node.id] = node }

    edges.each { |edge|
      node1 = find_node(edge.nid1)
      node1.edges << edge if edge.all_switches_on?
      node2 = find_node(edge.nid2)
      node2.edges << edge if edge.all_switches_on?
    }

    edges.each { |edge|
      edge.state = edge_tuden?(
        nid_plus,
        nid_minus,
        edges,
        nodes,
        edge
      )
    }
  end
end
