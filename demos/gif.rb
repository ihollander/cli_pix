require_relative "../lib/cli_pix"

url = "https://media3.giphy.com/media/dXLnSpMDt7CvzRwMa9/giphy.gif?cid=ecf05e47nkii9rn5xq6uc0tsoyc53rowe8zjnwrcydkfbw6w&rid=giphy.gif"
image = CliPix::Image.from_url(url, preprocess: true)
image.animate
