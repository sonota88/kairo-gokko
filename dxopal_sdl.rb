require "sdl"

RUBY_ENGINE = "opal"

def require_remote(path)
  path.sub!(/\.rb/, "")
  require "./#{path}"
end

def p_(*args)
  DXOpal.p_(*args)
end

module DXOpal

  C_BLACK = [255,   0,   0,   0]
  C_WHITE = [255, 255, 255, 255]

  M_LBUTTON = :m_lbutton

  @@p_count = 0

  def self.p_(*args)
    args.each { |arg| p arg } if @@p_count < 10
    @@p_count += 1
  end

  module Window

    @@width = 640
    @@height = 480
    @@last_update = Time.now

    class << self

      def width=(w)
        @@width = w
      end

      def height
        @@height
      end

      def height=(h)
        @@height = h
      end

      def bgcolor=(color)
        @@bgcolor = color
      end

      def to_rgb_a(color)
        if color.size == 4
          [color[1..3], color[0]]
        else
          [color, 255]
        end
      end

      def load_resources
        SDL.init(SDL::INIT_EVERYTHING)

        SDL::Mixer.open

        Sound.load_all

        @@screen = SDL.set_video_mode(
          @@width,
          @@height,
          16,
          SDL::SWSURFACE
        )

        yield
      end

      def handle_event(event)
        case event
        when SDL::Event::Quit
          exit
        when SDL::Event::MouseMotion
          Input.mouse_x = event.x
          Input.mouse_y = event.y
        when SDL::Event::MouseButtonDown
          if event.button == SDL::Mouse::BUTTON_LEFT
            DXOpal::Input.mouse_pushed_map_set(M_LBUTTON, true)
          end
        when SDL::Event::MouseButtonUp
          if event.button == SDL::Mouse::BUTTON_LEFT
            DXOpal::Input.mouse_pushed_map_set(M_LBUTTON, false)
          end
        end
      end

      def fill_bg
        draw_box_fill(0, 0, @@width, @@height, @@bgcolor)
      end

      def loop
        fps = 10
        interval_sec = 1 / fps.to_f

        while true
          while event = SDL::Event.poll
            handle_event(event)
          end

          if @@last_update + interval_sec < Time.now
            @@last_update = Time.now
            fill_bg
            yield
            @@screen.update_rect(0, 0, 0, 0)
          end
        end
      end

      def draw_line(x1, y1, x2, y2, color, z=0)
        rgb, alpha = to_rgb_a(color)
        antialias = false

        @@screen.draw_line(x1, y1, x2, y2, rgb, antialias, alpha)
      end

      def sdl_draw_box(x1, y1, x2, y2, color, fill)
        rgb, alpha = to_rgb_a(color)
        w = x2 - x1
        h = y2 - y1

        @@screen.draw_rect(x1, y1, w, h, rgb, fill, alpha)
      end

      def draw_box(x1, y1, x2, y2, color, z=0)
        sdl_draw_box(x1, y1, x2, y2, color, false)
      end

      def draw_box_fill(x1, y1, x2, y2, color, z=0)
        sdl_draw_box(x1, y1, x2, y2, color, true)
      end

      def sdl_draw_circle(x, y, r, color, fill)
        rgb, alpha = to_rgb_a(color)
        antialias = false

        @@screen.draw_circle(x, y, r, rgb, fill, antialias, alpha)
      end

      def draw_circle(x, y, r, color, z=0)
        sdl_draw_circle(x, y, r, color, false)
      end

      def draw_circle_fill(x, y, r, color, z=0)
        sdl_draw_circle(x, y, r, color, true)
      end

      def draw_font(x, y, string, font, option={})
        # dummy
      end
    end
  end

  class Sound
    @@map = {}

    class << self
      def register(name, *args, &block)
        path, _ = args
        @@map[name] = {
          path: path,
          sound: nil
        }
      end

      def [](name)
        @@map[name][:sound]
      end

      def load_all
        @@map.each { |name, inner_map|
          wave = SDL::Mixer::Wave.load(inner_map[:path])
          sound = Sound.new(wave)
          @@map[name][:sound] = sound
        }
      end
    end

    def initialize(wave)
      @wave = wave
    end

    def play
      SDL::Mixer.play_channel(-1, @wave, 0)
    end
  end

  module Input
    @@mouse_pushed_map = {}
    @@mouse_pushed_map[M_LBUTTON] = false

    @@mouse_x = 0
    @@mouse_y = 0

    class << self
      def mouse_pushed_map_set(code, val)
        @@mouse_pushed_map[code] = val
      end

      def mouse_x=(val)
        @@mouse_x = val
      end

      def mouse_y=(val)
        @@mouse_y = val
      end

      def mouse_x
        @@mouse_x
      end

      def mouse_y
        @@mouse_y
      end

      def mouse_push?(mouse_code)
        pushed = @@mouse_pushed_map[mouse_code]
        @@mouse_pushed_map[mouse_code] = nil
        pushed
      end

      def touch_x
        0 # not supported
      end

      def touch_y
        0 # not supported
      end

      def touch_push?
        false # not supported
      end
    end
  end

  class Font
    def initialize(size, fontname=nil, option={})
      nil # dummy
    end
  end
end
