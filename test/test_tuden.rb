require "minitest/autorun"

require_relative "../tuden"

class TestTuden < Minitest::Test
  def create_nodes(size)
    (1..size).map { |id| Tuden::Node.new(id) }
  end

  def create_edges(*xs)
    xs.map { |args|
      Tuden::Edge.new(
        args[0], # edge id
        args[1], # node id 1
        args[2], # node id 2
        args[3]  # switch state
      )
    }
  end

  def find_edge(edges, id)
    edges.find { |edge| edge.id == id }
  end

  def execute(
        edges,
        nodes,
        nid_plus,
        nid_minus
      )
    Tuden.update(
        edges,
        nodes,
        nid_plus,
        nid_minus
    )
  end

  # (1+) -1- (2) -2- (3-)
  def test_update_e2_1
    nodes = create_nodes(3)

    edges = create_edges(
      [1, 1, 2, true],
      [2, 2, 3, true]
    )

    execute(edges, nodes, 1, 3)

    assert_equal(true, find_edge(edges, 1).on?)
    assert_equal(true, find_edge(edges, 2).on?)
  end

  # (1+) -1x- (2) -2- (3-)
  def test_update_e2_2
    nodes = create_nodes(3)

    edges = create_edges(
      [1, 1, 2, !true],
      [2, 2, 3,  true]
    )

    execute(edges, nodes, 1, 3)

    assert_equal(false, find_edge(edges, 1).on?)
    assert_equal(false, find_edge(edges, 2).on?)
  end

  # (1+) -1- (2) -2- (3) -3- (4-)
  def test_update_e3_1
    nodes = create_nodes(4)

    edges = create_edges(
      [1, 1, 2, true],
      [2, 2, 3, true],
      [3, 3, 4, true]
    )

    execute(edges, nodes, 1, 4)

    assert_equal(true, find_edge(edges, 1).on?)
    assert_equal(true, find_edge(edges, 2).on?)
    assert_equal(true, find_edge(edges, 3).on?)
  end

  # (1+) -1- (2) -2- (3) -3x- (4-)
  def test_update_e3_2
    nodes = create_nodes(4)

    edges = create_edges(
      [1, 1, 2,  true],
      [2, 2, 3,  true],
      [3, 3, 4, !true]
    )

    execute(edges, nodes, 1, 4)

    assert_equal(false, find_edge(edges, 1).on?)
    assert_equal(false, find_edge(edges, 2).on?)
    assert_equal(false, find_edge(edges, 3).on?)
  end

  #          (1)
  #           |
  #           1
  #           |
  # (2+) -2- (3) -3- (4-)
  def test_update_e3_3
    nodes = create_nodes(4)

    edges = create_edges(
      [1, 1, 3, true],
      [2, 2, 3, true],
      [3, 3, 4, true]
    )

    execute(edges, nodes, 2, 4)

    assert_equal(!true, find_edge(edges, 1).on?)
    assert_equal( true, find_edge(edges, 2).on?)
    assert_equal( true, find_edge(edges, 3).on?)
  end

  # (1+) -1- (2) -2- (3) -3- (4) -4- (5-)
  def test_update_e4_1
    nodes = create_nodes(5)

    edges = create_edges(
      [1, 1, 2, true],
      [2, 2, 3, true],
      [3, 3, 4, true],
      [4, 4, 5, true]
    )

    execute(edges, nodes, 1, 5)

    assert_equal(true, find_edge(edges, 1).on?)
    assert_equal(true, find_edge(edges, 2).on?)
    assert_equal(true, find_edge(edges, 3).on?)
    assert_equal(true, find_edge(edges, 4).on?)
  end

  # (1+) -1- (2) -2- (3) -3x- (4) -4- (5-)
  def test_update_e4_2
    nodes = create_nodes(5)

    edges = create_edges(
      [1, 1, 2,  true],
      [2, 2, 3,  true],
      [3, 3, 4, !true],
      [4, 4, 5,  true]
    )

    execute(edges, nodes, 1, 5)

    assert_equal(false, find_edge(edges, 1).on?)
    assert_equal(false, find_edge(edges, 2).on?)
    assert_equal(false, find_edge(edges, 3).on?)
    assert_equal(false, find_edge(edges, 4).on?)
  end

  #       (1)
  #        |
  #        1
  #        |
  # (2)-2-(3)--*
  #        |   |
  #        3   4
  #        |   |
  #       (4)--*
  def test_update_e4_5
    nodes = create_nodes(4)

    edges = create_edges(
      [1, 1, 3, true],
      [2, 2, 3, true],
      [3, 3, 4, true],
      [4, 3, 4, true]
    )

    execute(edges, nodes, 1, 2)

    assert_equal( true, find_edge(edges, 1).on?)
    assert_equal( true, find_edge(edges, 2).on?)
    assert_equal(!true, find_edge(edges, 3).on?)
    assert_equal(!true, find_edge(edges, 4).on?)
  end

  #    (1+)
  #     |
  #     1
  #     |
  # *--(2)--2--(3)--*
  # |   |       |   |
  # 3   4       5   6
  # |   |       |   |
  # *--(4)--7--(5)--*
  #             |
  #             8
  #             |
  #            (6-)
  def test_update_e6_1
    nodes = create_nodes(6)

    edges = create_edges(
      [1, 1, 2, true],
      [2, 2, 3, true],
      [3, 2, 4, true],
      [4, 2, 4, true],
      [5, 3, 5, true],
      [6, 3, 5, true],
      [7, 4, 5, true],
      [8, 5, 6, true]
    )

    execute(edges, nodes, 1, 6)

    assert_equal(true, find_edge(edges, 1).on?)
    assert_equal(true, find_edge(edges, 2).on?)
    assert_equal(true, find_edge(edges, 3).on?)
    assert_equal(true, find_edge(edges, 4).on?)
    assert_equal(true, find_edge(edges, 5).on?)
    assert_equal(true, find_edge(edges, 6).on?)
    assert_equal(true, find_edge(edges, 7).on?)
    assert_equal(true, find_edge(edges, 8).on?)
  end

  #    (1+)
  #     |
  #     1
  #     |
  # *--(2)--2--(3)--*
  # |   |       |   |
  # 3   4x      5   6x
  # |   |       |   |
  # *--(4)--7--(5)--*
  #             |
  #             8
  #             |
  #            (6-)
  def test_update_e6_2
    nodes = create_nodes(6)

    edges = create_edges(
      [1, 1, 2,  true],
      [2, 2, 3,  true],
      [3, 2, 4,  true],
      [4, 2, 4, !true],
      [5, 3, 5,  true],
      [6, 3, 5, !true],
      [7, 4, 5,  true],
      [8, 5, 6,  true]
    )

    execute(edges, nodes, 1, 6)

    assert_equal( true, find_edge(edges, 1).on?)
    assert_equal( true, find_edge(edges, 2).on?)
    assert_equal( true, find_edge(edges, 3).on?)
    assert_equal(!true, find_edge(edges, 4).on?)
    assert_equal( true, find_edge(edges, 5).on?)
    assert_equal(!true, find_edge(edges, 6).on?)
    assert_equal( true, find_edge(edges, 7).on?)
    assert_equal( true, find_edge(edges, 8).on?)
  end

  #              (8)   (5)
  #               |     |
  #               8     4
  #               |     |
  # (3+)-2-(1)-3-(4)-5-(6)-6-(2)-7-(7-)
  #         |                 |
  #         *--------1--------*
  def test_update_e8_1
    nodes = create_nodes(8)

    edges = create_edges(
      [1, 1, 2, true],
      [2, 1, 3, true],
      [3, 1, 4, true],
      [4, 5, 6, true],
      [5, 6, 4, true],
      [6, 6, 2, true],
      [7, 2, 7, true],
      [8, 8, 4, true],
    )

    execute(edges, nodes, 3, 7)

    assert_equal( true, find_edge(edges,  1).on?)
    assert_equal( true, find_edge(edges,  2).on?)
    assert_equal( true, find_edge(edges,  3).on?)
    assert_equal(!true, find_edge(edges,  4).on?)
    assert_equal( true, find_edge(edges,  5).on?)
    assert_equal( true, find_edge(edges,  6).on?)
    assert_equal( true, find_edge(edges,  7).on?)
    assert_equal(!true, find_edge(edges,  8).on?)
  end

  def test_update_e13_1
    nodes = create_nodes(10)

    edges = create_edges(
      [ 1, 1, 5,  true],
      [ 2, 1, 8,  true],

      [ 3, 2, 4,  true],
      [ 4, 2, 5,  true],

      [ 5, 3,  4,  true],
      [ 6, 3,  7,  true],
      [ 7, 3, 10, !true],

      [ 8, 4,  9, !true],

      [ 9, 5, 10, !true],

      [10, 6,  7,  true],
      [11, 6, 10,  true],

      [12, 7, 8,  true],
      [13, 7, 9, !true],
    )

    execute(edges, nodes, 2, 1)

    assert_equal( true, find_edge(edges,  1).on?)
    assert_equal( true, find_edge(edges,  2).on?)
    assert_equal( true, find_edge(edges,  3).on?)
    assert_equal( true, find_edge(edges,  4).on?)
    assert_equal( true, find_edge(edges,  5).on?)
    assert_equal( true, find_edge(edges,  6).on?)
    assert_equal(!true, find_edge(edges,  7).on?)
    assert_equal(!true, find_edge(edges,  8).on?)
    assert_equal(!true, find_edge(edges,  9).on?)
    assert_equal(!true, find_edge(edges, 10).on?)
    assert_equal(!true, find_edge(edges, 11).on?)
    assert_equal( true, find_edge(edges, 12).on?)
    assert_equal(!true, find_edge(edges, 13).on?)
  end
end
