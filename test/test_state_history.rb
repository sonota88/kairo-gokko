# coding: utf-8

require_relative "./helper"
require "child_circuit"

class ChildCircuit
  class StateHistory
    attr_writer :data, :cur
  end
end

class TestStateHistory < Minitest::Test
  def prepare(*xs)
    sh = ChildCircuit::StateHistory.new(xs.size, "test")
    sh.data = xs.map { |x| x == 1 }
    sh.cur = xs.size - 1
    sh
  end

  def test_to_blocks__all_false
    sh = prepare(0, 0, 0)

    expected = [
      [0, 2, false]
    ]

    assert_equal(expected, sh.to_blocks)
  end

  def test_to_blocks__all_true
    sh = prepare(1, 1, 1)

    expected = [
      [0, 2, true]
    ]

    assert_equal(expected, sh.to_blocks)
  end

  def test_to_blocks__t_f
    sh = prepare(1, 1, 1, 0)

    expected = [
      [0, 2,  true],
      [3, 3, !true],
    ]

    assert_equal(expected, sh.to_blocks)
  end

  def test_to_blocks__f_t
    sh = prepare(0, 1, 1, 1)

    expected = [
      [0, 0, !true],
      [1, 3,  true],
    ]

    assert_equal(expected, sh.to_blocks)
  end

  def test_to_blocks__f_t_f
    sh = prepare(0, 1, 1, 0)

    expected = [
      [0, 0, !true],
      [1, 2,  true],
      [3, 3, !true],
    ]

    assert_equal(expected, sh.to_blocks)
  end

  # リングの開始位置が先頭でない場合
  def test_to_blocks__ring_shifted
    sh = prepare(1, 0, 0, 1)
    sh.cur = 1

    expected = [
      [0, 0, !true],
      [1, 2,  true],
      [3, 3, !true],
    ]

    assert_equal(expected, sh.to_blocks)
  end
end
