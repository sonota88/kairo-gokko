class Tuden
  def self.tuden?(switches)
    switches.all? { |switch| switch.on? }
  end
end
