# NOTE
# You'll need to install the av_capture gem to run this demo!
require "av_capture"
require_relative "../lib/cli_pix"

# uses av_capture gem to access webcam (OSX only)
session = AVCapture::Session.new
device = AVCapture.devices.find(&:video?)

session.run_with(device) do |connection|
  # give a little time for the camera to warm up...
  sleep 1
  
  # run a loop continuously
  loop do
    CliPix::Image.from_blob(connection.capture, flop: true).display
    # wait for next capture
    sleep 0.2
  end
end