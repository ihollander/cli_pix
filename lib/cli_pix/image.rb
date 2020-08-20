require "io/console"
require "mini_magick"
require "paint"

module CliPix
  class Image
  
    DEFAULT_OPTIONS = {
      autoscale: true,
      size: nil,
      flop: false,
      flip: false,
      mode: :color,
      preprocess: false
    }

    class << self  

      def read(blob, options = {})
        image = MiniMagick::Image.read(blob)
        self.new(image, options)
      end
      alias :from_blob :read

      def open(url, options = {})
        image = MiniMagick::Image.open(url)
        self.new(image, options)
      end
      alias :from_url :open
      alias :from_file :open

    end

    attr_reader :image, :options

    def initialize(image, options = {})
      @image = image
      @options = DEFAULT_OPTIONS.merge options
    end

    def display
      self.read do |text|
        # clear terminal
        clear_screen!
        puts text
      end
    end

    def animate(framerate = 0.2)
      self.read do |text|
        # clear terminal
        clear_screen! 
        puts text
        # wait
        sleep framerate
      end
    end

    # yields each text frame to the block
    def read
      process_image!
      if options[:preprocess]
        # | / - \  
        spinner = "|/-\\"
        text_frames = image.frames.map.with_index do |frame, index|
          print "Loading frame #{index + 1}/#{image.frames.length}... #{spinner[index % 4]} \r"
          if options[:mode] == :color
            convert_to_color(frame.get_pixels)
          else
            convert_to_ascii(frame.get_pixels)
          end
        end

        text_frames.each do |text_frame|
          yield text_frame
        end
      else
        image.frames.each do |frame|
          if options[:mode] == :color
            yield convert_to_color(frame.get_pixels)
          else
            yield convert_to_ascii(frame.get_pixels)
          end
        end
      end
    end

    private

    def clear_screen!
      print "\e[2J\e[f" 
    end

    def process_image!
      if options[:autoscale]
        width, height = get_scaled_dimensions
        image.resize "#{width}x#{height}"
      elsif options[:size]
        if options[:size].is_a? Array
          width, height = options[:size]
          image.resize "#{width}x#{height}"
        else
          image.resize "#{options[:size]}"
        end
      end
      
      image.colorspace "Gray" if options[:mode] == :ascii

      image.flip if options[:flip]
      image.flop if options[:flop]    
    end

    def convert_to_ascii(pixels)
      ascii_chars = " .:oO8@"

      text_image = ""

      pixels.each do |row|
        row.each do |rgb|
          char_index = ((rgb.first.to_f / 255) * ascii_chars.length).to_i
          text_image += (ascii_chars[char_index] || " ") * 2
        end
        text_image += "\n"
      end

      text_image
    end

    def convert_to_color(pixels)
      text_image = ""

      pixels.each do |row|
        row.each do |rgb|
          text_image += Paint["  ", nil, rgb]
        end
        text_image += "\n"
      end

      text_image
    end
    
    def get_scaled_dimensions
      # image width & height
      image_aspect_ratio = image.width.to_f / image.height

      # terminal width & height
      terminal_height, terminal_width = IO.console.winsize
      terminal_aspect_ratio = terminal_width.to_f / terminal_height

      # constrain (max width)
      photo_width = terminal_width > 50 ? 50 : terminal_width
      photo_height = photo_width / image_aspect_ratio
      # return [width, height]
      [ photo_width.to_i, photo_height.to_i ]
    end
  
  end
end
