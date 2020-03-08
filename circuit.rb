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
end
