class Circuit
  attr_reader :child_circuits

  def initialize(child_circuits)
    @child_circuits = child_circuits
  end
end
