# coding: utf-8
require "wavefile"
include WaveFile

params = {}

params["1"] = {
  seed: 1,
  envelope: [
    [0.0 , 0.5],
    [0.02, 0.0],
    [0.02, 1.0],
    [0.1 , 0.0],
  ]
}

params["1_2"] = {
  seed: 1,
  envelope: [
    [0.0 , 0.0],
    [0.005 , 0.5],
    [0.02, 0.0],
    [0.025, 1.0],
    [0.1 , 0.0],
  ]
}

params["2"] = {
  seed: 1,
  envelope: [
    [0.0 , 0.0],
    [0.005, 1.0],
    [0.08, 0.0],
    [0.085, 0.5],
    [0.1 , 0.0],
  ]
}

params["3"] = {
  seed: 1,
  envelope: [
    [0.0 , 0.5],
    [0.01, 0.5],

    [0.01, 0.0],
    [0.07, 0.0],

    [0.07, 1.0],
    [0.1 , 0.0],
  ]
}

PARAM = params["1"]

# --------------------------------

class NoiseOscillator
  def initialize(seed)
    r = Random.new(seed)
    @values = []
    10000.times {
      @values << r.rand * 2 - 1
    }
  end

  def generate(ratio)
    i = ((@values.size - 1) * ratio).floor
    @values[i]
  end

  def self.instance
    @@instance ||= NoiseOscillator.new(PARAM[:seed])
    @@instance
  end
end

def osc_noise(ratio)
  NoiseOscillator.instance.generate(ratio)
end

# --------------------------------

class Envelope
  class Block
    attr_reader :sec_beg, :v_beg
    attr_reader :sec_end, :v_end

    def initialize(
          sec_beg, v_beg,
          sec_end, v_end
        )
          @sec_beg = sec_beg
          @sec_end = sec_end
          @v_beg   = v_beg
          @v_end   = v_end
    end

    def include?(sec)
      @sec_beg <= sec && sec < @sec_end
    end

    def duration
      @sec_end - @sec_beg
    end
  end

  def initialize(param)
    @param = param
    @blocks = param.each_cons(2).map { |a, b|
      Block.new(a[0], a[1], b[0], b[1])
    }
  end

  def get_amp(sec)
    if sec == @param.last[0]
      return @param.last[1]
    end

    block = @blocks.find { |bl| bl.include?(sec) }

    x_ratio = (sec - block.sec_beg) / block.duration
    v_delta = (block.v_end - block.v_beg) * x_ratio
    block.v_beg + v_delta
  end
end

# --------------------------------

params = {}

ARGV.map { |arg|
  md = /^(.+?)=(.+)/.match(arg)
  k = md[1].to_sym
  v = md[2]

  params[k] =
    case k
    when :msec, :hz, :amp
      v.to_f
    when :out
      v
    else
      raise "invalid key (#{k})"
    end
}

# --------------------------------

# サンプリングレート（サンプル数 / 秒）
srate = 44100

# 増幅率 (0.0 <= x <= 1.0)
amp = params[:amp] || 0.1

duration_msec = params[:msec] || 100.0

# 全体のサンプル数
num_samples = srate * (duration_msec.to_f / 1000)

hz = params[:hz] || 440.0

# 1周期あたりのサンプル数
num_samples_per_cycle = srate / hz

out_file = params[:out] || "output.wav"

# --------------------------------

samples = []
envelope = Envelope.new(PARAM[:envelope])

(0 ... num_samples).each { |t|
  t_in_cycle = t % num_samples_per_cycle
  ratio = t_in_cycle / num_samples_per_cycle
  sec = t.to_f / srate

  sample = osc_noise(ratio)
  env_amp = envelope.get_amp(sec)
  samples << sample * env_amp * amp
}

# --------------------------------

buffer_format = Format.new(:mono, :float, srate)
file_format = Format.new(:mono, :pcm_16, srate)

buffer = Buffer.new(samples, buffer_format)

Writer.new(out_file, file_format) do |writer|
  writer.write(buffer)
end
