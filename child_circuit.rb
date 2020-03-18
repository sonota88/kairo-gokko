# coding: utf-8

require "set"

if RUBY_ENGINE == "opal"
  require_remote "./tuden.rb"
else
  ;
end

class ChildCircuit
  attr_reader :edges
  attr_reader :plus_poles
  attr_reader :minus_poles
  attr_reader :switches
  attr_reader :lamps
  attr_reader :not_relays

  def initialize(
        edges,
        plus_poles,
        minus_poles,
        switches,
        lamps,
        not_relays
      )
    @edges = edges
    @plus_poles = plus_poles
    @minus_poles = minus_poles
    @switches = switches
    @lamps = lamps
    @not_relays = not_relays
  end

  def to_plain
    {
      edges:       @edges      .map { |it| it.to_plain },
      plus_poles:  @plus_poles .map { |it| it.to_plain },
      minus_poles: @minus_poles.map { |it| it.to_plain },
      switches:    @switches   .map { |it| it.to_plain },
      lamps:       @lamps      .map { |it| it.to_plain },
      not_relays:  @not_relays .map { |it| it.to_plain }
    }
  end

  def self.from_plain(plain)
    edges       = plain["edges"      ].map { |it| Unit::Edge     .from_plain(it) }
    plus_poles  = plain["plus_poles" ].map { |it| Unit::PlusPole .from_plain(it) }
    minus_poles = plain["minus_poles"].map { |it| Unit::MinusPole.from_plain(it) }
    switches    = plain["switches"   ].map { |it| Unit::Switch   .from_plain(it) }
    lamps       = plain["lamps"      ].map { |it| Unit::Lamp     .from_plain(it) }
    not_relays  = plain["not_relays" ].map { |it| Unit::NotRelay .from_plain(it) }

    ChildCircuit.new(
      edges,
      plus_poles,
      minus_poles,
      switches,
      lamps,
      not_relays
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

  def update_lamps
    @lamps.each { |lamp|
      edge = @edges.find { |edge| edge.include_pos?(lamp.pos) }
      lamp.update(edge.on?)
    }
  end

  def neighbor?(pos1, pos2)
    pos1 == pos2.translate( 0, -1) ||
    pos1 == pos2.translate( 1,  0) ||
    pos1 == pos2.translate( 0,  1) ||
    pos1 == pos2.translate(-1,  0)
  end

  def find_neighbor_switch(pos)
    @switches.find { |switch|
      neighbor?(switch.pos, pos)
    }
  end

  def update_not_relays(circuit)
    switch_changed = false

    @not_relays.each { |not_relay|
      edge = @edges.find { |edge| edge.include_pos?(not_relay.pos) }
      not_relay.update(edge.on?)

      neighbor_switch = circuit.find_neighbor_switch(not_relay.pos)
      state_before_update = neighbor_switch.on?
      neighbor_switch.update(! not_relay.on?)

      if neighbor_switch.on? != state_before_update
        switch_changed = true
      end
    }

    switch_changed
  end

  def find_edge_including_pos(pos)
    @edges.find { |edge|
      edge.include_pos?(pos)
    }
  end

  def pretty_inspect
    to_plain.pretty_inspect
  end

end
