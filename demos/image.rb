require_relative "../lib/cli_pix"

file_path = "demos/image.png"
image = CliPix::Image.from_file(file_path)
image.display