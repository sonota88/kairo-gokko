require "wavefile"
include WaveFile

def osc_tri(ratio)
  if ratio < 0.25
    4 * ratio
  elsif ratio < 0.75
    -4 * ratio + 2
  else
    4 * ratio - 4
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

(0 ... num_samples).each { |t|
  t_in_cycle = t % num_samples_per_cycle
  ratio = t_in_cycle / num_samples_per_cycle
  samples << osc_tri(ratio) * amp
}

# --------------------------------

buffer_format = Format.new(:mono, :float, srate)
file_format = Format.new(:mono, :pcm_16, srate)

buffer = Buffer.new(samples, buffer_format)

Writer.new(out_file, file_format) do |writer|
  writer.write(buffer)
end
