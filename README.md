# CliPix

A Ruby library to display and animate images in your terminal.

## Requirements

This library uses the MiniMagick gem, which requires ImageMagick or GraphicsMagick to be installed on your system.

You can install it for OS X with homebrew:

```
brew install imagemagick
```

See the [requirements](https://github.com/minimagick/minimagick#requirements) from MiniMagick for more installation info.

## Installation

Add this line to your application's Gemfile:

```rb
gem 'cli_pix'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cli_pix

## Usage

Display an image from a file:

```rb
file_path = "demos/image.png"
image = CliPix::Image.from_file(file_path)
image.display
```

Display an image from a URL:

```rb
url = "https://f0.pngfuel.com/png/980/847/ruby-on-rails-logo-programming-language-rubygems-ruby-png-clip-art.png"
image = CliPix::Image.from_url(url)
image.display
```

Display animated gifs:

```rb
url = "https://media3.giphy.com/media/dXLnSpMDt7CvzRwMa9/giphy.gif?cid=ecf05e47nkii9rn5xq6uc0tsoyc53rowe8zjnwrcydkfbw6w&rid=giphy.gif"
image = CliPix::Image.from_url(url)
image.animate
```

Display data from a blob (to capture a webcam image, for example):

```rb
require "av_capture"

# uses av_capture gem to access webcam (OSX only)
session = AVCapture::Session.new
device = AVCapture.devices.find(&:video?)

session.run_with(device) do |connection|
  # give a little time for the camera to warm up...
  sleep 1
  
  # run a loop continuously
  loop do
    # connection.capture returns a blob
    image = CliPix::Image.from_blob(connection.capture, flop: true)
    image.display
    # wait for next capture
    sleep 0.2
  end
end
```

The `CliPix::Image#display` and `CliPix::Image#animate` methods will both output the image directly to your terminal. If you want more control, you can also use the `CliPix::Image#read` method to return a string representation of the image a block:

```rb
url = "https://media3.giphy.com/media/dXLnSpMDt7CvzRwMa9/giphy.gif?cid=ecf05e47nkii9rn5xq6uc0tsoyc53rowe8zjnwrcydkfbw6w&rid=giphy.gif"
image = CliPix::Image.from_url(url, preprocess: true)
# read will yield an image_string of each frame of the image to the block
image.read do |image_string|
  print `clear`
  puts image_string
  sleep 0.5
end
```

### Options

When creating an image, you can pass an options hash as a second argument. It takes the following options:

```rb
{
    autoscale: true,     # default: true. resize the image to fit the console window.
    size: nil,           # default: nil. you can provide an array of width and height [50, 30] or a string "50x30" to resize the image
    flip: false,          # default: false. if true, flip the image vertically
    flop: false,          # default: false. if true, flip the image horizontally
    mode: :color,        # default: :color. you can also use :ascii to display the image in ASCII mode.
    preprocess: false    # default: false. if true, process all frames of the image before displaying. useful for animated gifs.
}
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
